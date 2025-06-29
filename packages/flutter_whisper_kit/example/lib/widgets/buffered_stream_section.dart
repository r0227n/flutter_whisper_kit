import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for testing BufferedTranscriptionStream functionality
class BufferedStreamSection extends StatefulWidget {
  const BufferedStreamSection({super.key});

  @override
  State<BufferedStreamSection> createState() => _BufferedStreamSectionState();
}

class _BufferedStreamSectionState extends State<BufferedStreamSection> {
  // Stream instances
  TranscriptionStream? _transcriptionStream;
  BufferedTranscriptionStream? _bufferedStream;
  
  // Subscriptions
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<TranscriptionEvent>? _bufferedSubscription;
  
  // State variables
  final List<String> _streamLogs = [];
  bool _isStreamActive = false;
  
  // Buffer configuration
  int _bufferSize = 5;
  OverflowStrategy _overflowStrategy = OverflowStrategy.drop;
  
  // Statistics
  int _totalEvents = 0;
  int _droppedEvents = 0;
  int _transcriptionEvents = 0;
  int _progressEvents = 0;

  @override
  void dispose() {
    _disposeStreams();
    super.dispose();
  }

  void _disposeStreams() {
    _transcriptionSubscription?.cancel();
    _progressSubscription?.cancel();
    _bufferedSubscription?.cancel();
    _transcriptionStream?.dispose();
    _bufferedStream?.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _streamLogs.insert(0, '[${DateTime.now().millisecondsSinceEpoch % 100000}] $message');
      if (_streamLogs.length > 20) {
        _streamLogs.removeLast();
      }
    });
  }

  void _startStreamTesting() {
    _disposeStreams();
    
    setState(() {
      _isStreamActive = true;
      _streamLogs.clear();
      _totalEvents = 0;
      _droppedEvents = 0;
      _transcriptionEvents = 0;
      _progressEvents = 0;
    });

    // Create streams
    _transcriptionStream = TranscriptionStream();
    _bufferedStream = BufferedTranscriptionStream(
      maxBufferSize: _bufferSize,
      overflowStrategy: _overflowStrategy,
    );

    _addLog('Created streams with buffer size: $_bufferSize, strategy: $_overflowStrategy');

    // Subscribe to transcription stream results
    _transcriptionSubscription = _transcriptionStream!.results.listen(
      (result) {
        _addLog('📄 Transcription result: "${result.text.length > 30 ? '${result.text.substring(0, 30)}...' : result.text}"');
        setState(() {
          _transcriptionEvents++;
        });
      },
      onError: (error) => _addLog('❌ Transcription error: $error'),
    );

    // Subscribe to transcription stream progress
    _progressSubscription = _transcriptionStream!.progress.listen(
      (progress) {
        _addLog('📊 Progress: ${(progress * 100).toStringAsFixed(1)}%');
        setState(() {
          _progressEvents++;
        });
      },
      onError: (error) => _addLog('❌ Progress error: $error'),
    );

    // Subscribe to buffered stream events
    _bufferedSubscription = _bufferedStream!.events.listen(
      (event) {
        if (event is TranscriptionResultEvent) {
          _addLog('🔄 Buffered transcription: "${event.result.text.length > 20 ? '${event.result.text.substring(0, 20)}...' : event.result.text}"');
        } else if (event is ProgressEvent) {
          _addLog('🔄 Buffered progress: ${(event.progress * 100).toStringAsFixed(1)}%');
        }
      },
      onError: (error) => _addLog('❌ Buffered stream error: $error'),
    );

    _addLog('✅ Stream testing started');
  }

  void _stopStreamTesting() {
    _disposeStreams();
    setState(() {
      _isStreamActive = false;
    });
    _addLog('🛑 Stream testing stopped');
  }

  void _simulateEvents() {
    if (!_isStreamActive || _transcriptionStream == null || _bufferedStream == null) {
      _addLog('⚠️ Start stream testing first');
      return;
    }

    // Simulate a variety of events
    _simulateProgressEvents();
    _simulateTranscriptionEvents();
    _simulateBufferOverflow();
  }

  void _simulateProgressEvents() {
    final progressValues = [0.1, 0.3, 0.5, 0.7, 0.9];
    
    for (int i = 0; i < progressValues.length; i++) {
      Timer(Duration(milliseconds: i * 200), () {
        if (_isStreamActive) {
          final event = ProgressEvent(progressValues[i]);
          _transcriptionStream!.add(event);
          _bufferedStream!.add(event);
          
          setState(() {
            _totalEvents++;
          });
          
          _addLog('🟢 Sent progress event: ${(progressValues[i] * 100).toStringAsFixed(1)}%');
          
          // Check buffer size for overflow detection
          if (_bufferedStream!.currentBufferSize >= _bufferSize) {
            setState(() {
              _droppedEvents++;
            });
            _addLog('⚠️ Buffer overflow detected (size: ${_bufferedStream!.currentBufferSize})');
          }
        }
      });
    }
  }

  void _simulateTranscriptionEvents() {
    final transcriptionTexts = [
      'Hello world',
      'This is a test transcription',
      'Testing buffered streams',
      'Flutter WhisperKit is awesome',
      'Reactive programming patterns',
    ];

    for (int i = 0; i < transcriptionTexts.length; i++) {
      Timer(Duration(milliseconds: 1000 + i * 300), () {
        if (_isStreamActive) {
          final mockResult = TranscriptionResult(
            text: transcriptionTexts[i],
            segments: [],
            language: 'en',
            timings: const TranscriptionTimings(),
          );
          
          final event = TranscriptionResultEvent(mockResult);
          _transcriptionStream!.add(event);
          _bufferedStream!.add(event);
          
          setState(() {
            _totalEvents++;
          });
          
          _addLog('🟡 Sent transcription event: "${transcriptionTexts[i]}"');
          
          // Check buffer size for overflow detection
          if (_bufferedStream!.currentBufferSize >= _bufferSize) {
            setState(() {
              _droppedEvents++;
            });
            _addLog('⚠️ Buffer overflow detected (size: ${_bufferedStream!.currentBufferSize})');
          }
        }
      });
    }
  }

  void _simulateBufferOverflow() {
    // Send rapid events to test overflow handling
    Timer(const Duration(milliseconds: 3000), () {
      if (_isStreamActive) {
        _addLog('🔥 Simulating buffer overflow...');
        
        for (int i = 0; i < _bufferSize + 3; i++) {
          Timer(Duration(milliseconds: i * 50), () {
            if (_isStreamActive) {
              final event = ProgressEvent(0.1 + (i * 0.1));
              _bufferedStream!.add(event);
              
              setState(() {
                _totalEvents++;
              });
              
              if (_bufferedStream!.currentBufferSize >= _bufferSize) {
                setState(() {
                  _droppedEvents++;
                });
              }
            }
          });
        }
      }
    });
  }

  void _clearBuffer() {
    if (_bufferedStream != null) {
      _bufferedStream!.clearBuffer();
      _addLog('🧹 Buffer cleared (size now: ${_bufferedStream!.currentBufferSize})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'BufferedTranscriptionStream Testing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Configuration controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Text('Buffer Size: '),
                    Expanded(
                      child: Slider(
                        value: _bufferSize.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _bufferSize.toString(),
                        onChanged: _isStreamActive ? null : (value) {
                          setState(() {
                            _bufferSize = value.round();
                          });
                        },
                      ),
                    ),
                    Text(_bufferSize.toString()),
                  ],
                ),
                Row(
                  children: [
                    const Text('Overflow Strategy: '),
                    Expanded(
                      child: DropdownButton<OverflowStrategy>(
                        value: _overflowStrategy,
                        isExpanded: true,
                        onChanged: _isStreamActive ? null : (OverflowStrategy? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _overflowStrategy = newValue;
                            });
                          }
                        },
                        items: OverflowStrategy.values.map((strategy) {
                          return DropdownMenuItem<OverflowStrategy>(
                            value: strategy,
                            child: Text(strategy.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Control buttons
        Wrap(
          spacing: 8.0,
          children: [
            ElevatedButton(
              onPressed: _isStreamActive ? null : _startStreamTesting,
              child: const Text('Start Stream Testing'),
            ),
            ElevatedButton(
              onPressed: _isStreamActive ? _stopStreamTesting : null,
              child: const Text('Stop Testing'),
            ),
            ElevatedButton(
              onPressed: _isStreamActive ? _simulateEvents : null,
              child: const Text('Simulate Events'),
            ),
            ElevatedButton(
              onPressed: _isStreamActive ? _clearBuffer : null,
              child: const Text('Clear Buffer'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Statistics
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Events Sent: $_totalEvents'),
                Text('Transcription Events: $_transcriptionEvents'),
                Text('Progress Events: $_progressEvents'),
                Text('Dropped Events: $_droppedEvents'),
                if (_bufferedStream != null)
                  Text('Current Buffer Size: ${_bufferedStream!.currentBufferSize}'),
                Text('Strategy: ${_overflowStrategy.name}'),
                Text('Max Buffer Size: $_bufferSize'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Event log
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event Log', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: _streamLogs.isEmpty
                      ? const Text('No events yet. Start stream testing and simulate events.')
                      : ListView.builder(
                          itemCount: _streamLogs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1.0),
                              child: Text(
                                _streamLogs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}