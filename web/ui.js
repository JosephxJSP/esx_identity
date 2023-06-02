let check_firstname = false;
let check_lastname = false;
let check_sex = "m";
let min_char = 4;             // จำนวนตัวอักษรขั้นต่ำของชื่อ - นามสกุล

responsivescreen = () => {
  let innerWidth = window.innerWidth;
  let baseWidth = 1920;
  $(".main").css("zoom", ((innerWidth / baseWidth) * 105) / 100);
};
window.addEventListener("resize", responsivescreen);

$(window).ready(function() {
  responsivescreen();
  window.addEventListener('message', (e) => {
    let data = e.data;
    switch(data.type) {
      case "show":
        min_char = data.min_char;
        $(".info span").html(`ชื่อนามสกุลต้องเป็นภาษาอังกฤษ อย่างน้อย ${min_char} ตัวอักษร`);
        setDisplay(true);
      break;
      }
  });
});

isEnglish = function(input) {
  var englishPattern = /^[A-Za-z]+$/;
  return englishPattern.test(input);
}

capitalizeFirstChar = function(input) {
  if (input.length > 0) {
    return input.charAt(0).toUpperCase() + input.slice(1);
  }
  return input;
}

isCharGreater = function(char) {
  return char.length >= min_char;
}

$("#firstname input").on("change", function() {
  if ($("#firstname input").val() != "") {
    $("#firstname input").val(capitalizeFirstChar($("#firstname input").val()))
    if (isEnglish($("#firstname input").val()) && isCharGreater($("#firstname input").val())) {
      $("#firstname .icon .fa-circle-xmark").hide();
      $("#firstname .icon .fa-circle-check").show();
      check_firstname = true;
    } else {
      $("#firstname .icon .fa-circle-xmark").show();
      $("#firstname .icon .fa-circle-check").hide();
      check_firstname = false;
    }
  } else {
    $("#firstname .icon .fa-circle-xmark").hide();
    $("#firstname .icon .fa-circle-check").hide();
    check_firstname = true;
  }
});

$("#lastname input").on("change", function() {
  if ($("#lastname input").val() != "") {
    $("#lastname input").val(capitalizeFirstChar($("#lastname input").val()))
    if (isEnglish($("#lastname input").val()) && isCharGreater($("#lastname input").val())) {
      $("#lastname .icon .fa-circle-xmark").hide();
      $("#lastname .icon .fa-circle-check").show();
      check_lastname = true;
    } else {
      $("#lastname .icon .fa-circle-xmark").show();
      $("#lastname .icon .fa-circle-check").hide();
      check_lastname = false;
    }
  } else {
    $("#lastname .icon .fa-circle-xmark").hide();
    $("#lastname .icon .fa-circle-check").hide();
    check_lastname = false;
  }
});

$("#height input").on("change", function() {
  if ($("#height input").val() != "") {
    if ($("#height input").val() < 90) {
      $("#height input").val(90)
    } else if ($("#height input").val() > 200) {
      $("#height input").val(200)
    }
  }
});

$("#sex #male").on("click", function() {
  $("#sex #male").prop("checked", true);
  $("#sex #female").prop("checked", false);
  check_sex = "m";
});

$("#sex #female").on("click", function() {
  $("#sex #male").prop("checked", false);
  $("#sex #female").prop("checked", true);
  check_sex = "f";
});

$(".submit").on("click", function() {
  if (check_firstname && check_lastname && $("#birthday input").val() && $("#height input").val() >= 90 && $("#height input").val() <= 200) {
    $.post("https://esx_identity/submit", JSON.stringify({ 
      firstname: $("#firstname input").val(), 
      lastname: $("#lastname input").val(),
      height: $("#height input").val(),
      dateofbirth: $("#birthday input").val(),
      sex: check_sex
    }));
    setDisplay(false);
  }
});

setDisplay = function(status) {
  if (status) {
    $(".main").removeClass("fadeout");
    $(".main").addClass("fadein");
  } else {
    $(".main").removeClass("fadein");
    $(".main").addClass("fadeout");
  }
}