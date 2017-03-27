(function() {
  $(document).on('focus', '[data-behavior="input"]', function (e) {
    $(this).addClass('active');
  });

  $(document).on('blur', '[data-behavior="input"]', function (e) {
    $(this).removeClass('active');
  });
}());
