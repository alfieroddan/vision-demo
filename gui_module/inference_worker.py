from PySide6.QtCore import QObject, Signal, Slot
import time

class InferenceWorker(QObject):
    inference_done = Signal(str)

    @Slot(object)
    def run_inference(self, frame):
        # Simulate inference
        time.sleep(0.1)
        result = "Detected something"
        self.inference_done.emit(result)
