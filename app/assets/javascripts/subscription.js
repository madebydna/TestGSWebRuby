var GS = GS || {};

GS.subscription = GS.subscription || {};

GS.subscription.sponsorsSignUp = function () {
  $.ajax({
    type: 'POST',
    url: "/gsr/user/subscriptions",
    data: {subscription:
      {list: "sponsor",
        message: "You've signed up to receive sponsors updates"
      }
    }
  })
};
