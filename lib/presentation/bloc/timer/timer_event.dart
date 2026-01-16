import 'package:equatable/equatable.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimerEvent extends TimerEvent {
  final String taskId;

  const StartTimerEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class StopTimerEvent extends TimerEvent {
  const StopTimerEvent();
}

class TimerTickEvent extends TimerEvent {
  const TimerTickEvent();
}

class ResumeTimersEvent extends TimerEvent {
  const ResumeTimersEvent();
}
