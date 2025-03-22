# ARBQEN Image Restoration Tool

## 1. Introduction
ARBQEN (Adaptive Robust Bilateral Quaternion-based Elastic Net) is an image restoration method based on quaternions and elastic net optimization. This tool effectively restores images affected by blur and noise by combining quaternion representation with elastic net optimization.

## 2. Features
- Supports image restoration for various types of blurs (Gaussian blur, motion blur, and mean blur).
- Combines quaternion representation to better handle multi-channel information of color images.
- Implements optimization based on the ADMM (Alternating Direction Method of Multipliers) framework, supporting sparse and low-rank optimization.

## 3. Code Structure
- **Main Function**: `ARBQENrestore`, which is responsible for image reading, preprocessing, blur simulation, restoration, and result display.
- **Dependent Library**: Utilizes the `aelasticnetR` function from a modified version of [LibADMM](https://github.com/canyilu/LibADMM) to implement elastic net optimization.

## 4. Parameter Description
### Input Parameters
- `type`: Type of blur, with values of 1 (Gaussian blur), 2 (motion blur), and 3 (mean blur).
- `original_image_path`: Path to the original image.
- `lambda1`, `lambda2`: Regularization parameters for elastic net, controlling sparsity and low-rankness.
- `opts`: Options for the ADMM algorithm.
- `beta`: Balancing parameter for the elastic net.

### Output Parameter
- `restored_image`: The restored image.

## 5. Usage
1. Save the code as `ARBQENrestore.m`.
2. Ensure that the modified version of `aelasticnetR` is available in your MATLAB path.
3. Run the following command in MATLAB:
   ```matlab
   restored_image = ARBQENrestore(1, 'path/to/your/image.jpg', 0.1, 0.01, opts, 0.5);
   ```
   Here, `1` indicates Gaussian blur type, `'path/to/your/image.jpg'` is the path to the original image, `0.1` and `0.01` are regularization parameters, `opts` are the ADMM options, and `0.5` is the balancing parameter.

## 6. Example
### Input Image
![Original Image](example_images/original_image.jpg)

### Blurred Image
![Damaged Image](example_images/damaged_image.jpg)

### Restored Image
![Restored Image](example_images/restored_image.jpg)

## 7. Dependencies
- [LibADMM](https://github.com/canyilu/LibADMM): The original library provides the `elasticnetR` function. The modified version of `aelasticnetR` is used in this tool to implement elastic net optimization.

## 8. References
- C. Lu, J. Feng, S. Yan, and Z. Lin. A unified alternating direction method of multipliers by majorization minimization. IEEE Transactions on Pattern Analysis and Machine Intelligence, 40(3):527–541, 2018.

## 9. Notes on `aelasticnetR`
The `aelasticnetR` function used in this tool is a modified version of the original `elasticnetR` from LibADMM. The modifications are designed to better suit the requirements of the ARBQEN algorithm, such as improved handling of quaternion-based data and specific optimization settings for image restoration tasks. For detailed implementation and modifications, please refer to the source code of `aelasticnetR` provided with this tool.
