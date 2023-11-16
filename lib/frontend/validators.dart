import 'package:form_field_validator/form_field_validator.dart';
	
final nameValidator = MultiValidator([
    RequiredValidator(errorText: "予定名を入力してください"),
]);