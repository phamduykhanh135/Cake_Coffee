import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField reusableTextFromFilel(
    String text,
    IconData icon,
    bool isPassword,
    bool isPhone,
    TextEditingController controller,
    String? Function(String?)? validator) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    enableSuggestions: !isPassword,
    autocorrect: !isPassword,
    cursorColor: Colors.grey,
    style: TextStyle(color: Colors.grey.withOpacity(0.9)),
    decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
        labelText: text,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.grey,
              style: BorderStyle.none,
            ))),
    keyboardType: isPhone
        ? TextInputType.phone
        : isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
    inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
    maxLength: isPhone ? 10 : null,
    validator: validator,
  );
}

TextFormField reusable_passwordTextFromFilel(
    String text,
    IconData icon,
    bool isPassword,
    TextEditingController controller,
    String? Function(String?)? validator,
    bool isObscure, // Thêm tham số để truyền giá trị _isObscure từ bên ngoài
    VoidCallback toggleObscure // Thêm callback để cập nhật _isObscure
    ) {
  return TextFormField(
    controller: controller,
    obscureText: isObscure,
    cursorColor: Colors.grey,
    style: TextStyle(color: Colors.grey.withOpacity(0.9)),
    decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed:
                    toggleObscure, // Sử dụng callback để cập nhật _isObscure
              )
            : null,
        labelText: text,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.grey,
              style: BorderStyle.none,
            ))),
    validator: validator,
  );
}

Widget reusableElevatedButton({
  required String text,
  required VoidCallback onPressed,
  required GlobalKey<FormState> formKey,
  required TextEditingController emailController,
  required TextEditingController passwordController,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double width = constraints.maxWidth * 0.8;
      if (text.length * 10.0 > width) {
        width = text.length * 10.0;
      }

      return Container(
        width: width,
        height: 50,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA0522D).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final isValid = formKey.currentState!.validate();
            if (!isValid) return;
            onPressed();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.red;
                }
                return const Color(0xFFA0522D);
              },
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    },
  );
}

void signIn(BuildContext context, String email, String password) {
  // Replace this with your sign-in logic
  print('Signing in with email: $email, password: $password');
  // Example: Navigate to home screen after successful sign-in
  Navigator.pushReplacementNamed(context, '/home');
}

Widget reusable_registerElevatedButton({
  required String text,
  required VoidCallback onPressed,
  required GlobalKey<FormState> formKey,
  required TextEditingController nameController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double width = constraints.maxWidth * 0.8;
      if (text.length * 10.0 > width) {
        width = text.length * 10.0;
      }

      return Container(
        width: width,
        height: 50,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA0522D).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Kiểm tra tính hợp lệ của biểu mẫu
            final isValid = formKey.currentState!.validate();
            // Nếu biểu mẫu không hợp lệ, dừng lại
            if (!isValid) return;

            // Tiến hành đăng ký nếu biểu mẫu hợp lệ
            print('Biểu mẫu hợp lệ');
            //  đăng ký nếu các điều khoản được đồng ý
            onPressed(); // gọi hàm onPressed từ Register_Screen
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.red;
                }
                return const Color(0xFFA0522D);
              },
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    },
  );
}

Widget roundedElevatedButton({
  required VoidCallback onPressed,
  required String text,
  required Color backgroundColor,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.red; // Màu khi nút được nhấn
          }
          return backgroundColor; // Màu mặc định
        },
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Độ bo của góc
          // Các thuộc tính khác của đường viền (nếu cần)
        ),
      ),
      elevation:
          WidgetStateProperty.resolveWith<double>((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return 6; // Độ nổi khi nút được nhấn
        }
        return 4; // Độ nổi mặc định
      }),
    ),
    child: Padding(
      padding:
          const EdgeInsets.all(0.0), // Khoảng cách giữa văn bản và viền nút
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}
