(function() {
  var toggleDropdown = function (e) {
    e.preventDefault();
    var $inputDiv = $(this).closest('[data-behavior="dropdown"]');
    if ($inputDiv.hasClass('open')) {
      closeDropdown.apply(this);
    } else {
      openDropdown.apply(this);
    }
  };

  var openDropdown = function () {
    var $inputDiv = $(this).closest('[data-behavior="dropdown"]');
    $inputDiv.addClass('active open');
    $inputDiv.find('.select-options').focus();
  };

  var closeDropdown = function (e) {
    if ($(e.target).is('[type="checkbox"]')) {
      return true;
    }

    var $inputDiv = $(this).closest('[data-behavior="dropdown"]');
    $inputDiv.removeClass('open');
    if ($inputDiv.data().multiSelect) {
      updateSelectCheckboxPlaceholder($inputDiv);
    } else {
      var isEmpty = ($inputDiv.find('select').val() === '');
      $inputDiv.toggleClass('active', isEmpty);
    }
  };

  var updateFakeSelect = function (value, $inputDiv) {
    var $option = $inputDiv.find('.select-options li[data-value="' + value + '"]');
    var label = $option.text();

    $inputDiv.find('.selectable').removeClass('selected');
    $option.addClass('selected');
    $inputDiv.find('.display-selected').html('<span>' + label + '</span>');
    $inputDiv.addClass('active').removeClass('open');
  };

  var updateSelectCheckboxPlaceholder = function ($inputDiv) {
    var $checked = $inputDiv.find('input:checked'),
        $selected = $inputDiv.find('.display-selected'),
        label = $inputDiv.children('label').text(),
        placeholder = 'Add ' + label;
    if ($checked.length === 1) {
      placeholder = $checked.first().siblings('label').text();
    } else if ($checked.length > 1) {
      placeholder = $checked.length + ' ' + label;
    }
    $selected.text(placeholder);
  };

  var optionSelected = function () {
    if ($(this).hasClass('input-check')) {
      $(this).find('[type="checkbox"]').click();
    } else {
      var $inputDiv = $(this).closest('[data-behavior="dropdown"]');
      var value = $(this).data('value');
      $inputDiv.find('select').val(value).change();
    }
  };

  var selectChanged = function () {
    updateFakeSelect($(this).val(), $(this).closest('[data-behavior="dropdown"]'));
  };

  $(document).on('mousedown', '[data-behavior="dropdown"] .display-selected', toggleDropdown);
  $(document).on('blur focusout', '[data-behavior="dropdown"] .select-options', closeDropdown);
  $(document).on('click', '[data-behavior="dropdown"] .select-options li.selectable', optionSelected);
  $(document).on('change', '[data-behavior="dropdown"] select', selectChanged);
}());
