import sys
from PySide6.QtCore import QThread, Slot, QObject
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from frame_receiver import FrameReceiver
from inference_worker import InferenceWorker

class Controller(QObject):
    def __init__(self, ui_root):
        super().__init__()
        self.ui_root = ui_root

    @Slot(str)
    def update_label(self, text):
        self.ui_root.findChild(QObject, "inferenceLabel").setProperty("text", text)

def main():
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load("ui.qml")
    if not engine.rootObjects():
        return -1

    root_obj = engine.rootObjects()[0]
    controller = Controller(root_obj)

    # Frame Receiver thread and object
    frame_thread = QThread()
    frame_receiver = FrameReceiver()
    frame_receiver.moveToThread(frame_thread)

    # When thread starts, call frame_receiver.start()
    frame_thread.started.connect(frame_receiver.start)

    # Inference thread and object
    inference_thread = QThread()
    inference_worker = InferenceWorker()
    inference_worker.moveToThread(inference_thread)
    inference_thread.start()

    # Connect signals
    frame_receiver.frame_received.connect(inference_worker.run_inference)
    inference_worker.inference_done.connect(controller.update_label)

    # Start the frame receiver thread's event loop
    frame_thread.start()

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
