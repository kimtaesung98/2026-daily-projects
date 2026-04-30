class BufferOverflowException implements Exception {
  final String message;
  final int currentSize;

  BufferOverflowException(
    this.currentSize, [
    this.message = 'Memory buffer limit exceeded.',
  ]);

  @override
  String toString() => 'BufferOverflowException: $message (Size: $currentSize)';
}
