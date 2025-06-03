import onnxruntime as ort
import cv2
from collections import deque
import time


def get_best_available_onnx_provider():
    """
    Just return a ORT provider 
    """
    providers = ort.get_available_providers()
    preferred_order = ['CUDAExecutionProvider', 'CoreMLExecutionProvider', 'CPUExecutionProvider']

    for provider in preferred_order:
        if provider in providers:
            return provider
    # Fallback if none found (very unlikely)
    return providers[0] if providers else None


def probe_video_devices(max_devices: int = 10):
    available_devices = []
    for i in range(max_devices):
        cap = cv2.VideoCapture(i)
        if cap is None or not cap.isOpened():
            # device index i not available
            continue
        ret, _ = cap.read()
        if ret:
            available_devices.append(i)
        cap.release()
    return available_devices


class FPSTracker:
    def __init__(self, max_frames: int = 50):
        """
        Initialize the FPSTracker with a fixed size deque to store timestamps.
        :param max_frames: Maximum number of recent frames to consider for FPS calculation.
        """
        self.max_frames = max_frames
        self.frame_buffer = deque(maxlen=max_frames)

    def add_frame(self, timestamp=None):
        """
        Add a frame's timestamp to the tracker.
        :param timestamp: Timestamp of the frame (defaults to current time if not provided).
        """
        if timestamp is None:
            timestamp = time.time()
        self.frame_buffer.append(timestamp)

    def compute_fps(self):
        """
        Compute FPS based on the timestamps in the deque.
        :return: Calculated FPS as a float.
        """
        if len(self.frame_buffer) < 2:
            return 0.0  # Not enough data to compute FPS

        # Time difference between the first and last frame in the deque
        time_span = self.frame_buffer[-1] - self.frame_buffer[0]
        if time_span == 0:
            return float(
                "inf"
            )  # Prevent division by zero if all timestamps are identical

        return (len(self.frame_buffer) - 1) / time_span