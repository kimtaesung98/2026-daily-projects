Core Grid Architecture

Concept
DOT → ROUND → VOLUME

Core
main.dart
grid_screen.dart

Rules
1 core must not change
2 models define grid nodes
3 features expand from models
4 business logic never exists in core

Structure

lib
 core
  main.dart
  grid_screen.dart
 model
 feature

This project follows the Core Grid Architecture described in ARCHITECTURE.md.

Do not modify the core.
Only expand features from models.

We are currently adding a weather feature node.