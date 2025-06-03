from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtGui import QImage
import numpy as np
from abc import ABC
import onnxruntime as ort

class BaseInference(ABC):
    def run(self, frame): raise NotImplementedError()


class NoInference(BaseInference):
    def run(self, frame: np.ndarray):
        return frame


class EfficientDetInference(BaseInference):
    def run(self, frame):
        return "effdet result"


class InferenceWorker(QObject):
    inference_done = Signal(QImage)

    def __init__(self, ort_device: str):
        super().__init__()
        self.device = ort_device
        self.inference_runner = NoInference()
    
    @Slot(str)
    def set_inference_runner(self, runner_string: str):
        if runner_string == "None":
            self.inference_runner = NoInference()

    @Slot(object)
    def run_inference(self, rgb_frame: np.ndarray):
        # expects a 3 channel RGB image (RGB24)
        height, width, _ = rgb_frame.shape
        qimage = QImage(rgb_frame.data, width, height, 3 * width, QImage.Format_RGB888).copy()
        self.inference_done.emit(qimage)