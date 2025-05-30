import sys
from PySide6.QtCore import QObject, Signal, Slot, Property, QSize, QThread
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QImage
from PySide6.QtQuick import QQuickImageProvider
from frame_receiver import FrameReceiver
from inference_worker import InferenceWorker


class FrameProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.Image)
        self.current_image = QImage(640, 480, QImage.Format_RGB32)
        self.current_image.fill(0xff000000)  # black initially

    def requestImage(self, id, size, requestedSize):
        if self.current_image.isNull():
            return QImage(640, 480, QImage.Format_RGB32).fill(0xff000000)

        if requestedSize.width() > 0 and requestedSize.height() > 0:
            return self.current_image.scaled(requestedSize)
        return self.current_image

    def update_image(self, qimage: QImage):
        self.current_image = qimage


class Controller(QObject):
    imageSizeChanged = Signal()

    def __init__(self, frame_provider):
        super().__init__()
        self.frame_provider = frame_provider
        self._image_size = QSize(640, 480)

    @Property(QSize, notify=imageSizeChanged)
    def imageSize(self):
        return self._image_size

    @imageSize.setter
    def imageSize(self, size):
        if size != self._image_size:
            self._image_size = size
            self.imageSizeChanged.emit()

    @Slot(QImage)
    def update_image(self, qimage: QImage):
        self.frame_provider.update_image(qimage)
        self.imageSize = qimage.size()

        # Notify QML to refresh image source by changing the source URL
        # Find the root object and the image inside it
        root = self.parent()
        if root is not None:
            inference_image = root.findChild(QObject, "inferenceImage")
            if inference_image:
                import time
                base_source = "image://frameprovider/current"
                new_source = f"{base_source}?t={time.time()}"
                inference_image.setProperty("source", new_source)


def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    frame_provider = FrameProvider()
    engine.addImageProvider("frameprovider", frame_provider)

    controller = Controller(frame_provider)
    engine.rootContext().setContextProperty("controller", controller)

    engine.load("ui.qml")
    if not engine.rootObjects():
        return -1

    # Set controller's parent to root for easy access if needed
    root_obj = engine.rootObjects()[0]
    controller.setParent(root_obj)

    # Create and expose Controller instance to QML
    controller = Controller(frame_provider)
    controller.setParent(root_obj)  # Set parent to root for easy access
    engine.rootContext().setContextProperty("controller", controller)

    # Setup threads and workers
    frame_thread = QThread()
    frame_receiver = FrameReceiver()
    frame_receiver.moveToThread(frame_thread)
    frame_thread.started.connect(frame_receiver.start)

    inference_thread = QThread()
    inference_worker = InferenceWorker()
    inference_worker.moveToThread(inference_thread)
    inference_thread.start()

    # Connect signals
    frame_receiver.frame_received.connect(inference_worker.run_inference)
    inference_worker.inference_done.connect(controller.update_image)

    frame_thread.start()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
