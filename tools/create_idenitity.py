import onnx
from onnx import helper, TensorProto

# Define the model
input_tensor = helper.make_tensor_value_info('input', TensorProto.FLOAT, None)
output_tensor = helper.make_tensor_value_info('output', TensorProto.FLOAT, None)

identity_node = helper.make_node('Identity', inputs=['input'], outputs=['output'])

graph_def = helper.make_graph([identity_node], 'IdentityGraph', [input_tensor], [output_tensor])

# Specify opset version 22
opset_imports = [helper.make_operatorsetid("", 22)]

model_def = helper.make_model(graph_def, opset_imports=opset_imports, producer_name='onnx-example')

# Set IR version 4 corresponds to ONNX Runtime max supported IR 10
model_def.ir_version = 4

# Save model
onnx.save(model_def, 'models/identity.onnx')
