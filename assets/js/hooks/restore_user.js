export default RestoreUser = {
  mounted() {
    const user = sessionStorage.getItem('user');
    this.pushEvent('restore_user', { user_name: user });
  },
};
