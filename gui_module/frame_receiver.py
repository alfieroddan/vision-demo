from PySide6.QtCore import QObject, Signal, QTimer, Slot
import cv2

class FrameReceiver(QObject):
    # Emitting a frame (e.g., numpy array)
    frame_received = Signal(object)

    def __init__(self):
        super().__init__()
        self.cap = cv2.VideoCapture(0)
        self.timer = None

    @Slot()
    def start(self):
        # Create the timer inside the thread context
        self.timer = QTimer()
        self.timer.timeout.connect(self.read_frame)
        self.timer.start(30)  # ~33 fps

    def read_frame(self):
        ret, frame = self.cap.read()
        if ret:
            self.frame_received.emit(frame)

    @Slot()
    def stop(self):
        if self.timer:
            self.timer.stop()
        self.cap.release()
