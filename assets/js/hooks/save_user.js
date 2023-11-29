export default SaveUser = {
  mounted() {
    this.handleEvent(
      'save_user',
      ({ user_name: user, redirect_url: redirect_url }) => {
        console.log(redirect_url);
        window.location = redirect_url;
        sessionStorage.setItem('user', user);
      }
    );

    this.handleEvent('show_error', ({ error_message: error_message }) => {
      alert(error_message);
    });
  },
};
