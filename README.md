# hpemerger plugin for MADS

This is a Filter plugin for [MADS](https://github.com/MADS-NET/MADS). 
*Required MADS version: 1.2.2.*

## Overview

**HpeMerger** is a C++ plugin designed to merge and process multi-camera human pose estimation (HPE) data. It takes as input 3D joint positions and their associated uncertainty (covariance) matrices from multiple cameras, fuses them using a weighted approach, and outputs a single, robust estimate for each joint. The plugin is built to be used within the [MADS](https://github.com/mads-organization/mads-core) framework and leverages the [Eigen](https://eigen.tuxfamily.org/) library for linear algebra and [nlohmann::json](https://github.com/nlohmann/json) for JSON handling.

---

## Features

- **Multi-camera fusion:** Combines joint detections from multiple cameras using uncertainty-aware weighting.
- **Covariance handling:** Each joint's uncertainty is represented and propagated using full 3x3 covariance matrices.
- **Temporal weighting:** Older detections are down-weighted using a configurable time normalization parameter.
- **Velocity estimation:** Computes joint velocities for prediction and smoothing.
- **Flexible joint mapping:** Supports customizable joint names and ordering via configuration.
- **JSON I/O:** Input and output are handled as JSON objects for easy integration.

---

## Functional Block Scheme

```plaintext
+-------------------+
|  Input JSON Data  |
+-------------------+
          |
          v
+-------------------+
|  load_data()      |
| - Parse input     |                    
| - Update joint    |                    
|   positions,      |                    
|   covariances,    |                    
|   timestamps      |                    
+-------------------+                    
          |                              
          v                              
+-------------------+                    
|  process()        |                    
| - Predict current |                    
|   positions       |                    
| - Compute weights |                   
|   (time, cameras) |                    
| - Fuse positions  |                    
|   and covariances |                    
| - Estimate        |                    
|   velocities      |                    
+-------------------+                    
          |                              
          v                              
+-------------------+                    
| Output JSON Data  |
+-------------------+
```

---

## Usage

### 1. **Initialization**

The plugin is instantiated and configured with parameters, including the joint map and time normalization factor.

```cpp
HpemergerPlugin plugin;
json params;
params["joint_map"] = { "NOS_", "NEC_", ... }; // Optional: custom joint names
params["time_weight_normalization"] = 500000000; // Optional: time normalization (ns)
plugin.set_params(&params);
```

### 2. **Input Data Format**

Input data should be a JSON object with the following structure:

```json
{
  "agent_id": "hpe",
  "hostname": "PC-1234",
  "timecode": 123456.78,
  "timestamp": {
    "$date": "YYYY-MM-DDTHH:mm:ss.SSS±ZZZZ"
  },
  "typ": "3D",

  "NEC_": {
    "ncm": 1,
    "crd": [0.1, 1.2, -0.3],
    "unc": [0.01, 0.02, 0.03, 0.001, 0.002, 0.003]
  },
  ...
}
```
- `"ncm"`: Number of cameras used to detect this joint
- `"crd"`: 3D coordinates `[x, y, z]`
- `"unc"`: Covariance matrix in the order `[xx, yy, zz, xy, xz, yz]`

### 3. **Processing**

Call `load_data()` for each new input, then call `process()` to perform fusion and get the output.

```cpp
plugin.load_data(input_json);
plugin.process(output_json);
```

### 4. **Output Data Format**

The output JSON contains the fused results for each joint:

```json
{
  "agent_id": "hpe-merger",
  "hostname": "PC-5678",
  "timecode": 123456.78,
  "timestamp": {
    "$date": "YYYY-MM-DDTHH:mm:ss.SSS±ZZZZ"
  },
  "ts": 1234567890123456,
  "type": "FSD",

  "NEC_": {
    "ncm": 2,
    "crd": [0.12, 1.45, -0.33],
    "unc": [0.01, 0.02, 0.03, 0.001, 0.002, 0.003]
  },
  ...
}
```
- `"ncm"`: Number of cameras used for this joint
- `"crd"`: Fused 3D coordinates
- `"unc"`: Fused covariance matrix

---

## Main Classes and Methods

### `HpemergerPlugin`

- **`set_params(void const *params)`**  
  Initializes the plugin with configuration parameters (joint map, time normalization, etc.).

- **`load_data(json const &input, string topic = "")`**  
  Loads new joint data from a camera, updating internal buffers.

- **`process(json &out)`**  
  Performs fusion of all available data, computes velocities, and writes the output JSON.

- **`get_camera_index(string const &camera_name)`**  
  Maps camera names to indices, dynamically resizing internal storage as new cameras appear.

---

## Configuration Parameters

- **`joint_map`**: Array of joint names (default: ["NOS_", "NEC_", ...]).
- **`time_weight_normalization`**: Scalar for time-based weighting (default: 500000000 ns).

---

## Dependencies

- [Eigen](https://eigen.tuxfamily.org/) (for matrix operations)
- [nlohmann::json](https://github.com/nlohmann/json) (for JSON parsing)
- [MADS Framework](https://github.com/mads-organization/mads-core) (for plugin integration)

---

## Example

```cpp
#include <filter.hpp>
#include <nlohmann/json.hpp>
#include <pugg/Kernel.h>
#include <vector>
#include <array>
#include <Eigen/Dense>

int main(int argc, char const *argv[])
{
  HpemergerPlugin plugin;
  json params;
  json input, output;

  // Set example values to params
  params["test"] = "value";

  // Set the parameters
  plugin.set_params(&params);

  // Set input data
  input["data"] = {
    {"AX", 1},
    {"AY", 2},
    {"AZ", 3}
  };

  // Set input data
  plugin.load_data(input);
  std::cout << "Input: " << input.dump(2) << std::endl;

  // Process data
  plugin.process(output);
  std::cout << "Output: " << output.dump(2) << std::endl;

  return 0;
}
```

---

## License

This project is distributed under the MIT License.

---

## Contact

For questions or contributions, please open an issue or pull request on the repository.

---

**Block Diagram**

```plaintext
+-------------------+      +-------------------+      +-------------------+
|  Camera 1 Input   |      |  Camera 2 Input   | ...  |  Camera N Input   |
+-------------------+      +-------------------+      +-------------------+
          \                        |                          /
           \_______________________|_________________________/
                                   |
                                   v
                        +-----------------------+
                        |   HpemergerPlugin     |
                        |  (Fusion & Filtering) |
                        +-----------------------+
                                   |
                                   v
                        +-----------------------+
                        |   Output JSON Data    |
                        +-----------------------+
```


## Supported platforms

Currently, the supported platforms are:

* **Linux** 
* **MacOS**
* **Windows**


## Installation

Linux and MacOS:

```bash
cmake -Bbuild -DCMAKE_INSTALL_PREFIX="$(mads -p)"
cmake --build build -j4
sudo cmake --install build
```

Windows:

```powershell
cmake -Bbuild -DCMAKE_INSTALL_PREFIX="$(mads -p)"
cmake --build build --config Release
cmake --install build --config Release
```


## INI settings

The plugin supports the following settings in the INI file:

```ini
[hpemerger]
# Describe the settings available to the plugin
```

All settings are optional; if omitted, the default values are used.


TO RUN: 
mads-filter hpemerger.plugin
