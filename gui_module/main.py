import sys
import time
from PySide6.QtCore import Qt, QObject, Signal, Slot, Property, QSize, QThread, QTimer
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QImage
from PySide6.QtQuick import QQuickImageProvider
from frame_receiver import FrameReceiver
from inference_worker import InferenceWorker
import utils


class FrameProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.Image)
        self.current_image = QImage(640, 480, QImage.Format_RGB32)
        self.current_image.fill(0xff000000)  # black initially
    
    def requestImage(self, id, size, requestedSize):
        if requestedSize.width() > 0 and requestedSize.height() > 0:
            scaled = self.current_image.scaled(requestedSize, Qt.KeepAspectRatio)
            return scaled
        return self.current_image

    def update_image(self, qimage: QImage):
        self.current_image = qimage.copy()


class Controller(QObject):
    imageSizeChanged = Signal()
    sourceUrlChanged = Signal()
    deviceChanged = Signal()
    fpsChanged = Signal()

    def __init__(self, frame_provider):
        super().__init__()
        self.frame_provider = frame_provider
        self._image_size = QSize(640, 480)
        self._source_url = "image://frameprovider/current"
        self._device_name = ""
        self._fps_str = "~"
        self.fps_tracker = utils.FPSTracker(max_frames=50)

        # Create QTimer
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_fps)
        self.timer.start(10000)

    @Property(str, notify=deviceChanged)
    def device(self):
        return self._device_name

    @device.setter
    def device(self, name: str):
        if self._device_name != name:
            self._device_name = name
            self.deviceChanged.emit()

    @Property(str, notify=fpsChanged)
    def fps(self):
        return self._fps_str

    @fps.setter
    def fps(self, fps: str):
        if self._fps_str != fps:
            self._fps_str = fps 
            self.fpsChanged.emit()
    
    def update_fps(self):
        fps = self.fps_tracker.compute_fps()
        self.fps = str(round(fps))

    @Property(QSize, notify=imageSizeChanged)
    def imageSize(self):
        return self._image_size

    @imageSize.setter
    def imageSize(self, size):
        if size != self._image_size:
            self._image_size = size
            self.imageSizeChanged.emit()

    @Property(str, notify=sourceUrlChanged)
    def sourceUrl(self):
        return self._source_url

    @sourceUrl.setter
    def sourceUrl(self, value):
        if self._source_url != value:
            self._source_url = value
            self.sourceUrlChanged.emit()

    @Slot(QImage)
    def update_image(self, qimage: QImage):
        self.fps_tracker.add_frame()
        self.frame_provider.update_image(qimage)
        self.imageSize = qimage.size()
        self.sourceUrl = f"image://frameprovider/current?{time.time()}"


def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Image provider setup
    frame_provider = FrameProvider()
    engine.addImageProvider("frameprovider", frame_provider)

    # Controller setup (only once!)
    controller = Controller(frame_provider)
    engine.rootContext().setContextProperty("controller", controller)

    # Load QML
    engine.load("ui.qml")
    if not engine.rootObjects():
        return -1

    # Set parent of controller to root QML object for access to children
    root_obj = engine.rootObjects()[0]
    controller.setParent(root_obj)

    # Set device
    ort_device = utils.get_best_available_provider()
    controller.device = ort_device

    # Setup FrameReceiver in its own thread
    frame_thread = QThread()
    frame_receiver = FrameReceiver()
    frame_receiver.moveToThread(frame_thread)
    frame_thread.started.connect(frame_receiver.start)

    # Setup InferenceWorker in its own thread
    inference_thread = QThread()
    inference_worker = InferenceWorker(ort_device=ort_device)
    inference_worker.moveToThread(inference_thread)

    # Start inference thread
    inference_thread.start()

    # Connect signals
    frame_receiver.frame_received.connect(inference_worker.run_inference)
    inference_worker.inference_done.connect(controller.update_image)

    # Start frame receiving
    frame_thread.start()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
