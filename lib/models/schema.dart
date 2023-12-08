import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('member', [
    Column.text('first_name'),
    Column.text('last_name'),
    Column.text('EAN'),
    Column.text('ZIP'),
    Column.text('is_active'),
    Column.text('birth_number'),
    Column.text('city'),
    Column.text('is_confirmed'),
    Column.text('email'),
    Column.text('phone'),
    Column.text('is_in_CAS'),
    Column.text('gender'),
    Column.text('note'),
    Column.text('street'),
    Column.text('parent_phone'),
    Column.text('parent_email')
  ]),
  Table('trainer', [
    Column.text('member_id'),
    Column.text('qualification'),
    Column.text('email'),
    Column.text('salary'),
    Column.text('last_background_sync'),
    Column.text('fcm_token'),
    Column.text('last_fcm_token_update'),
    Column.text('bg_sync_time')
  ]),
  Table('cloth', [Column.text('size'), Column.text('cloth_type_id')]),
  Table('cloth_type', [
    Column.text('name'),
    Column.text('image_src'),
    Column.text('gender'),
    Column.text('is_borrowable')
  ]),
  Table('discipline', [
    Column.text('czech_name'),
    Column.text('is_run'),
    Column.text('english_name'),
    Column.text('result_name'),
  ]),
  Table('group', [
    Column.text('name'),
    Column.text('training_day'),
    Column.text('school_year_id')
  ]),
  Table(
      'group_has_member', [Column.text('group_id'), Column.text('member_id')]),
  Table('group_has_trainer',
      [Column.text('group_id'), Column.text('trainer_id')]),
  Table('piece_of_cloth', [Column.text('cloth_id'), Column.text('member_id')]),
  Table('race', [
    Column.text('name'),
    Column.text('description'),
    Column.text('datetime_start'),
    Column.text('datetime_end'),
    Column.integer('sync'),
    Column.text('place'),
  ]),
  Table('race_has_discipline', [
    Column.text('datetime'),
    Column.text('race_id'),
    Column.text('discipline_id'),
    Column.text('category'),
  ]),
  Table('race_result', [
    Column.text('result'),
    Column.text('race_id'),
    Column.text('discipline_id'),
    Column.text('member_id'),
    Column.text('category'),
  ]),
  Table('school_year', [
    Column.text('name'),
    Column.text('time_change1'),
    Column.text('time_change2'),
    Column.text('is_active')
  ]),
  Table('sign_up_form', [
    Column.text('first_name'),
    Column.text('last_name'),
    Column.text('birth_number'),
    Column.text('health'),
    Column.text('health_insurance'),
    Column.text('street'),
    Column.text('city'),
    Column.text('parent_first_name'),
    Column.text('parent_last_name'),
    Column.text('parent_email'),
    Column.text('parent_phone'),
    Column.text('is_paid'),
    Column.text('trainings_per_week'),
    Column.text('school_year_id'),
    Column.text('datetime')
  ]),
  Table('training', [
    Column.text('group_id'),
    Column.text('datetime'),
    Column.text('length'),
    Column.text('description')
  ]),
  Table('training_has_absent_member', [
    Column.text('training_id'),
    Column.text('member_id'),
    Column.text('is_excused')
  ]),
  Table('training_has_trainer',
      [Column.text('training_id'), Column.text('trainer_id')]),
  Table('training_result', [
    Column.text('result'),
    Column.text('training_id'),
    Column.text('discipline_id'),
    Column.text('member_id')
  ]),
]);
