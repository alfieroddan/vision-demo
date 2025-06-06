from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtGui import QImage
import numpy as np
from abc import ABC
import onnxruntime as ort
import warnings
import yaml
import cv2
from typing import Tuple


def to_uint8_image(frame: np.ndarray) -> np.ndarray:
    frame = np.clip(frame, 0, 255)  # Ensure values are in valid range
    return frame.astype(np.uint8)


class BaseInference(ABC):
    def run(self, frame): raise NotImplementedError()


class IdentityInference(BaseInference):
    def __init__(self, device):
        self.device = device
        self.session = ort.InferenceSession('models/identity.onnx', providers=self.device)
        self.input_name = self.session.get_inputs()[0].name
        self.output_name = self.session.get_outputs()[0].name
    
    def run(self, frame: np.ndarray):
        # Ensure float32 and memory contiguity
        frame = np.ascontiguousarray(frame).astype(np.float32)

        # Run inference
        result = self.session.run([self.output_name], {self.input_name: frame})[0]

        return to_uint8_image(result)


class Yolo11n(BaseInference):
    def __init__(self, device, confidence=0.25, iou=0.7):
        self.confidence = confidence
        self.iou = iou
        self.session = ort.InferenceSession('models/yolo11n.onnx', providers=device)
        with open("models/coco8.yaml", "r") as f:
            self.classes = yaml.safe_load(f)["names"]
    
    def letterbox(self, img, size=640):
        h, w = img.shape[:2]
        r = size / max(h, w)
        new_h, new_w = int(h * r), int(w * r)
        img = cv2.resize(img, (new_w, new_h))
        dh, dw = (size - new_h) // 2, (size - new_w) // 2
        img = cv2.copyMakeBorder(img, dh, size-new_h-dh, dw, size-new_w-dw, cv2.BORDER_CONSTANT, value=(114,114,114))
        return img, r, (dw, dh)

    def nms(self, boxes, scores, iou_thresh):
        indices = np.argsort(scores)[::-1]
        keep = []
        while len(indices) > 0:
            i = indices[0]
            keep.append(i)
            if len(indices) == 1: break
            
            iou = self.compute_iou(boxes[i], boxes[indices[1:]])
            indices = indices[1:][iou <= iou_thresh]
        return keep

    def compute_iou(self, box1, boxes):
        x1 = np.maximum(box1[0], boxes[:, 0])
        y1 = np.maximum(box1[1], boxes[:, 1])
        x2 = np.minimum(box1[2], boxes[:, 2])
        y2 = np.minimum(box1[3], boxes[:, 3])
        
        inter = np.maximum(0, x2 - x1) * np.maximum(0, y2 - y1)
        area1 = (box1[2] - box1[0]) * (box1[3] - box1[1])
        area2 = (boxes[:, 2] - boxes[:, 0]) * (boxes[:, 3] - boxes[:, 1])
        return inter / (area1 + area2 - inter)

    def run(self, frame):
        h, w = frame.shape[:2]
        img, r, (dw, dh) = self.letterbox(frame)
        img = img[..., ::-1].transpose(2, 0, 1)[None].astype(np.float32) / 255.0
        
        pred = self.session.run(None, {self.session.get_inputs()[0].name: img})[0][0].T
        pred = pred[pred[:, 4] > self.confidence]
        
        if len(pred) == 0: return frame
        
        boxes = pred[:, :4]
        scores = pred[:, 4]
        classes = np.argmax(pred[:, 5:85], axis=1)
        
        # xywh to xyxy
        boxes[:, [0,2]] = boxes[:, [0,0]] + np.column_stack([-boxes[:, 2]/2, boxes[:, 2]/2])
        boxes[:, [1,3]] = boxes[:, [1,1]] + np.column_stack([-boxes[:, 3]/2, boxes[:, 3]/2])
        
        keep = self.nms(boxes, scores, self.iou)
        boxes, scores, classes = boxes[keep], scores[keep], classes[keep]
        
        # Scale to original
        boxes[:, [0,2]] = (boxes[:, [0,2]] - dw) / r
        boxes[:, [1,3]] = (boxes[:, [1,3]] - dh) / r
        boxes = np.clip(boxes, 0, [w, h, w, h])
        
        # Draw
        result = frame.copy()
        for box, score, cls in zip(boxes.astype(int), scores, classes):
            cv2.rectangle(result, box[:2], box[2:], (0,255,0), 2)
            cv2.putText(result, f"{self.classes[cls]} {score:.2f}", 
                       (box[0], box[1]-5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,255,0), 1)
        
        return result


class InferenceWorker(QObject):
    inference_done = Signal(QImage)

    def __init__(self, ort_device: str):
        super().__init__()
        self.device = ort_device
        self.inference_runner = IdentityInference(device=self.device)
    
    @Slot(str)
    def set_inference_runner(self, runner_string: str):
        if runner_string == "Identity":
            self.inference_runner = IdentityInference(device=self.device)
        elif runner_string == "Semantic Segmentation":
            self.inference_runner = Yolo11n(device=self.device)
        else:
            warnings.warn(f"No inference with name: {runner_string}")

    @Slot(object)
    def run_inference(self, rgb_frame: np.ndarray):
        # here we run the inference worker
        rgb_frame = self.inference_runner.run(rgb_frame)
        # expects a 3 channel RGB image (RGB24)
        height, width, _ = rgb_frame.shape
        qimage = QImage(rgb_frame.data, width, height, 3 * width, QImage.Format_RGB888).copy()
        self.inference_done.emit(qimage)
