from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtGui import QImage
import time
import numpy as np

class InferenceWorker(QObject):
    inference_done = Signal(QImage)

    @Slot(object)
    def run_inference(self, rgb_frame: np.ndarray):
        # Simulate inference delay
        time.sleep(0.1)

        height, width, channels = rgb_frame.shape
        if channels == 3:
            qimage = QImage(rgb_frame.data, width, height, 3 * width, QImage.Format_RGB888).copy()
        else:
            raise ValueError("Unsupported number of channels in frame")

        self.inference_done.emit(qimage)