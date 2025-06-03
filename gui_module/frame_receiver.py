from PySide6.QtCore import QObject, Signal, QTimer, Slot
from abc import ABC
import cv2


class Provider(ABC):
    """Base class for a provider"""
    def get_frame(self): raise NotImplementedError()
    def close(self): raise NotImplementedError()


class WebcamProvider(Provider):
    """Simple on device webcam provider"""

    def __init__(self, index: int = 0):
        self.index = index
        self.cap = cv2.VideoCapture(index)

    def get_frame(self):
        ret, frame = self.cap.read()
        if ret:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        return ret, frame
    
    def close(self):
        self.cap.release()


class GStreamerProvider(Provider):
    """Simple on device webcam provider"""

    def __init__(self, gstring: str = ""):
        self.gstring = gstring
        self.cap = cv2.VideoCapture(gstring)

    def get_frame(self):
        ret, frame = self.cap.read()
        if ret:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        return ret, frame

    def close(self):
        self.cap.release()


class FrameReceiver(QObject):
    frame_received = Signal(object)

    def __init__(self):
        super().__init__()
        self.provider = WebcamProvider()
        self.timer = None

    @Slot("QVariantMap")
    def set_provider(self, config: dict):
        # stop timer whilst provider switching
        if self.timer:
            self.timer.stop()

        provider_type = config.get("type")
        print(f"[FrameReceiver] Config received: {config}")

        # Stop and clean up existing provider if any
        if self.provider:
            try:
                self.provider.close()
            except Exception as e:
                print(f"Error closing provider: {e}")

        if provider_type == "webcam":
            index = int(config.get("device_index", 0))
            self.provider = WebcamProvider(index=index)

        elif provider_type == "gstreamer":
            pipeline = config.get("pipeline", "")
            self.provider = GStreamerProvider(pipeline)

        else:
            print(f"Unknown provider type: {provider_type}")
        
        # start timer again
        if self.timer:
            self.timer.start()

    @Slot()
    def start(self):
        # Create the timer inside the thread context
        self.timer = QTimer()
        self.timer.timeout.connect(self.read_frame)
        self.timer.start(16)  # target ~60 fps

    def read_frame(self):
        ret, frame = self.provider.get_frame()
        if ret:
            self.frame_received.emit(frame)

    @Slot()
    def stop(self):
        if self.timer:
            self.timer.stop()
        self.provider.close()
