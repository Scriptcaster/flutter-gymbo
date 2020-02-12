abstract class authWidgets {
  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new TextFormField(
        decoration: new InputDecoration(
        hintText: 'Email',
        icon: new Icon(
          Icons.mail,
          color: Colors.grey,
        )),
        controller: emailInputController,
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
      ),
    );
  }
}