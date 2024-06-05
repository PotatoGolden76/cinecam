
# CineCam: Cinematic Camera Control Plugin for Godot

## Overview

CineCam is a plugin that provides a simple but powerful method to deal with multi-camera systems and animating camera transitions. It aims to allow the user to replicate real life cinematographic movement in 3D scenes, offering advanced camera control and a transition systems integrated seamlessly with the Godot Editor.

## Key Features

- **Virtual Cameras:** Customizable camera nodes offering multiple modes for following and aiming at targets.
- **Camera Transitions:** A custom editor windows and resource allows the customisation of transitions between cameras.

## Usage

### Setting Up a Virtual Camera

1. Add `VirtualCamera` nodes to your scene.
2. Configure the virtual cameras using the Inspector.
3. Create a `TransitionDictionary` .tres file in your project
4. Create a `CameraDirector` in your scene, and add a `Camera3D` child to it
5. Assign the resource created above to your director node
6. Configure your transitions using the custom plugin window

## Example

A basic example scene can be found in the `examples` folder

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This plugin was developed as part of my bachelor thesis at Babeș-Bolyai University Cluj-Napoca, Faculty of Mathematics and Computer Science.

## Contact

For any questions or issues, please open an issue on the GitHub repository or contact the author.