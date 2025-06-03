from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtGui import QImage
import numpy as np
import onnxruntime as ort


class InferenceWorker(QObject):
    inference_done = Signal(QImage)

    def __init__(self, ort_device: str):
        super().__init__()
        self.device = ort_device

    @Slot(object)
    def run_inference(self, rgb_frame: np.ndarray):
        height, width, channels = rgb_frame.shape
        if channels == 3:
            qimage = QImage(rgb_frame.data, width, height, 3 * width, QImage.Format_RGB888).copy()
        else:
            raise ValueError("Unsupported number of channels in frame")
        self.inference_done.emit(qimage)