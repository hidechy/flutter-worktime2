import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_time_list_state.freezed.dart';

@freezed
class WorkTimeListState with _$WorkTimeListState {
  const factory WorkTimeListState({
    required String ym,
    required String summary,
    required String company,
    required String genba,
    required String salary,
    required String hour,
    required String daily,
  }) = _WorkTimeListState;
}
