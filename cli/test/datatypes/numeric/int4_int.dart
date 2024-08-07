import 'package:supabase/supabase.dart';
import '../../models/generated_classes.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import '../../utils.dart';

Future<void> performIntegerTest(SupabaseClient supabase) async {
  // int4 = four-byte signed integer
  int insertInt4 = 2147483647; // max value for int4
  int updatedInt4 = -2147483648; // min value for int4

  // Tests for integer
  test('Testing Integer Create', () async {
    await cleanup(supabase, supabase.numeric_types);
    var createResult = await createInteger(supabase, insertInt4);
    expect(createResult, null);
  });

  test('Testing Integer Update', () async {
    var updateResult = await updateInteger(supabase, insertInt4, updatedInt4);
    expect(updateResult, null);
  });

  test('Testing Integer Read', () async {
    var readResult = await readInteger(supabase);
    assert(readResult is List<NumericTypes>);
    expect(readResult!.length, 1);
    expect(readResult[0].col_integer, isA<int>());
    expect(readResult[0].col_integer, updatedInt4);
  });
}

Future<Object?> createInteger(SupabaseClient supabase, int insertVal) async {
  try {
    await supabase.numeric_types.insert(NumericTypes.insert(
      col_integer: insertVal,
    ));
    return null;
  } catch (error) {
    return error;
  }
}

Future<Object?> updateInteger(
    SupabaseClient supabase, int oldValue, int value) async {
  try {
    await supabase.numeric_types
        .update(NumericTypes.update(col_integer: value))
        .eq(NumericTypes.c_col_integer, oldValue);
    return null;
  } catch (error) {
    print("updateInteger error");
    print(error);
    return error;
  }
}

Future<List<NumericTypes>?> readInteger(SupabaseClient supabase) async {
  try {
    var res = await supabase.numeric_types
        .select()
        .withConverter(NumericTypes.converter);
    return res;
  } catch (error) {
    print("readInteger error");
    print(error);
    return null;
  }
}
