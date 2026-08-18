// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GönüllüNet';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageOption => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String comingSoon(String feature) {
    return '$feature coming soon!';
  }

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get accountAndActions => 'Account & Actions';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get myPosts => 'My Posts';

  @override
  String get notifications => 'Notifications';

  @override
  String get events => 'Events';

  @override
  String get myPublishedEvents => 'My Published Events';

  @override
  String get myJoinedEvents => 'Joined Events';

  @override
  String get application => 'Application';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get corporateMember => 'Corporate Member';

  @override
  String get volunteerMember => 'Volunteer Member';

  @override
  String nextLevel(Object xp) {
    return 'Next Level: $xp XP';
  }

  @override
  String get xpInfo =>
      'You can earn XP by joining events, posting and interacting.\nBadges: Observer (0+), Active (100+), Pioneer (500+), Master (1500+), Legend (5000+)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get accountSettingsSection => 'Account Settings';

  @override
  String get deleteAccount => 'Delete My Account';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutUs => 'About Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account?';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get yesDelete => 'YES, DELETE';

  @override
  String get onboardTitle1 => 'Welcome to\nGönüllüNet';

  @override
  String get onboardDesc1 =>
      'Discover acts of kindness around you, join the community and start making a difference right away.';

  @override
  String get onboardTitle2 => 'Discover\nEvents';

  @override
  String get onboardDesc2 =>
      'Find the nearest volunteering events on the map and filter them by your interests.';

  @override
  String get onboardTitle3 => 'Stronger\nTogether';

  @override
  String get onboardDesc3 =>
      'Come together with NGOs and volunteers to be part of big changes.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardStart => 'Start Exploring';

  @override
  String get onboardContinue => 'Continue';

  @override
  String get emailEmpty => 'Email cannot be empty.';

  @override
  String get invalidEmailFormat => 'Invalid email format.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get passwordEmpty => 'Password cannot be empty.';

  @override
  String get passwordWeak =>
      'Password is too weak. It must be at least 8 characters and contain upper/lowercase letters, a digit and a special character.';

  @override
  String get nameEmpty => 'First name cannot be empty.';

  @override
  String get surnameEmpty => 'Last name cannot be empty.';

  @override
  String get ngoNameEmpty => 'NGO name cannot be empty.';

  @override
  String get almostReady => 'Almost Ready!';

  @override
  String get selectUserType => 'Please select your user type to continue.';

  @override
  String get roleVolunteer => 'Volunteer';

  @override
  String get roleVolunteerDesc => 'Find and join events';

  @override
  String get roleNgo => 'NGO';

  @override
  String get roleNgoDesc => 'Create an organization profile';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle =>
      'Continue your journey of kindness where you left off.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'hello@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Log In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signupVolunteerTagline => 'Become a Volunteer, Join Events';

  @override
  String get signupNgoTagline => 'Organization Portal';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signupVolunteerSubtitle =>
      'Enter your details to become a volunteer.';

  @override
  String get signupNgoSubtitle => 'Join to connect with volunteers.';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get ngoName => 'NGO Name';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginAction => 'Log in';

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navOrganizations => 'Organizations';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get assistant => 'Assistant';

  @override
  String get homeGreeting => 'Hello, 👋';

  @override
  String get retry => 'Try Again';

  @override
  String get noPostsYet => 'No posts yet.\nOrganizations will post here soon.';

  @override
  String get ngoPostsSection => 'ORGANIZATION POSTS';

  @override
  String get upcomingEvents => 'UPCOMING EVENTS';

  @override
  String get seeAll => 'See All';

  @override
  String get seeAllShort => 'See All';

  @override
  String get defaultVolunteerName => 'Volunteer';

  @override
  String get defaultNgoName => 'NGO';

  @override
  String get errorTitle => 'An Error Occurred';

  @override
  String get checkingProfile => 'Checking Profile Information...';

  @override
  String get userSessionNotFound => 'User session not found.';

  @override
  String get verificationEmailResent => 'Verification email sent again.';

  @override
  String get tooManyRequests => 'Too many requests. Please wait a few minutes.';

  @override
  String emailSendFailed(String error) {
    return 'Could not send email: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get cancelRegistrationTooltip => 'Cancel registration';

  @override
  String get verificationLinkSent =>
      'We sent a verification link to this address. The app will continue automatically once you click the link.';

  @override
  String get countdownExpired => 'expired';

  @override
  String get countdownRemaining => 'remaining';

  @override
  String get checkInbox =>
      'Check your inbox. You will be redirected automatically once you click the verification link.';

  @override
  String get timeUp => 'Time\'s Up!';

  @override
  String get linkExpiredDesc =>
      'The verification link has expired. Press the button below to send a new link.';

  @override
  String get sending => 'Sending...';

  @override
  String get sendNewLink => 'Send New Link';

  @override
  String get resendLink => 'Resend Link';

  @override
  String resendIn(Object seconds) {
    return 'Resend ($seconds s)';
  }

  @override
  String get cancelReturnLogin => 'Cancel — return to login screen';

  @override
  String get allEvents => 'All Events';

  @override
  String get noEventsFound => 'No events yet\nor no results match the filter.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get eventsSubtitle => 'Discover and join volunteer events';

  @override
  String get filter => 'Filter';

  @override
  String get fullScreen => 'Full Screen';

  @override
  String statUpcoming(Object count) {
    return '$count Upcoming';
  }

  @override
  String statOnMap(Object count) {
    return '$count On Map';
  }

  @override
  String imagePickFailed(String error) {
    return 'Could not pick image: $error';
  }

  @override
  String get titleEmpty => 'Title cannot be empty.';

  @override
  String get selectLocationOnMap => 'Please select a location on the map.';

  @override
  String get selectAllTimes =>
      'Please select start, end and application deadline times.';

  @override
  String get endBeforeStart => 'End date cannot be before the start date!';

  @override
  String get lastApplyAfterStart =>
      'Application deadline cannot be after the start date!';

  @override
  String get lastApplyInPast => 'Application deadline cannot be in the past!';

  @override
  String get selectPlaceholder => 'Select';

  @override
  String get eventCreatedSuccess => 'Content created successfully!';

  @override
  String get newEvent => 'New Event';

  @override
  String get publish => 'Publish';

  @override
  String get eventTitleHint => 'Event Title';

  @override
  String get eventDescriptionHint => 'Tell something about the event...';

  @override
  String get type => 'Type';

  @override
  String get category => 'Category';

  @override
  String get quotaOptional => 'Quota (Optional)';

  @override
  String get location => 'Location';

  @override
  String get change => 'Change';

  @override
  String get selectLocationFromMap => 'Select Location from Map';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get lastApplyDateLabel => 'Application Deadline';

  @override
  String get addImageOptional => 'Add Image (Optional)';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEnvironment => 'Environment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryAnimalRights => 'Animal Rights';

  @override
  String get categoryDisaster => 'Disaster';

  @override
  String get categoryArt => 'Art';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryCulture => 'Culture';

  @override
  String get typeEvent => 'Event';

  @override
  String get typeProject => 'Project';

  @override
  String get eventFull => 'Full';

  @override
  String get beFirstToJoin => 'Be the first!';

  @override
  String get filterTitle => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get cityLabel => 'City';

  @override
  String get eventCategoryLabel => 'Event Category';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get apply => 'Apply';

  @override
  String get organizer => 'Organizer';

  @override
  String get loading => 'Loading...';

  @override
  String get applicationStat => 'Application';

  @override
  String get participantStat => 'Participant';

  @override
  String personCount(Object count) {
    return '$count People';
  }

  @override
  String get soFar => 'So far';

  @override
  String get manageApplications => 'Manage Applications';

  @override
  String get eventExpired => 'This event has expired';

  @override
  String get applicationClosed => 'Applications are closed';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get leaveEvent => 'Leave Event';

  @override
  String get applicationPending => 'Application Pending (Cancel)';

  @override
  String get leaveEventConfirm => 'Are you sure you want to leave the event?';

  @override
  String get cancelApplicationConfirm =>
      'Are you sure you want to cancel your application?';

  @override
  String get applicationSubmitted =>
      'Your application has been submitted, awaiting approval!';

  @override
  String get projectLetterPrompt =>
      'To apply for this project, please write a letter stating your intention. This letter will be reviewed by the organization for your application to be approved.';

  @override
  String get letterHint => 'Write your intention in detail here...';

  @override
  String get send => 'Send';

  @override
  String get dateLabel => 'Date';

  @override
  String get details => 'Details';

  @override
  String get quotaFull => 'Quota Full';

  @override
  String get intentLetter => 'Letter of Intent';

  @override
  String charCountLabel(Object count, Object min) {
    return '$count / $min characters';
  }

  @override
  String lastApplyPrefix(String date) {
    return 'Deadline: $date';
  }

  @override
  String get searchEvent => 'Search events...';

  @override
  String get shrink => 'Shrink';

  @override
  String get noEventsForCriteria => 'No events match this criteria.';

  @override
  String get examine => 'View';

  @override
  String participantCount(Object count) {
    return '$count participants';
  }

  @override
  String get userNotFound => 'User not found';

  @override
  String get noEventsPublished => 'You haven\'t published any events yet.';

  @override
  String get noEventsJoined => 'You haven\'t joined any events yet.';

  @override
  String get searchLocationHint => 'Search location...';

  @override
  String get selectingLocation => 'Selecting location...';

  @override
  String get selectedAddress => 'Selected Address';

  @override
  String get addressFinding => 'Finding address...';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String likeCountLabel(Object count) {
    return '$count Likes';
  }

  @override
  String commentCountLabel(Object count) {
    return '$count Comments';
  }

  @override
  String get like => 'Like';

  @override
  String get comment => 'Comment';

  @override
  String get descriptionEmpty => 'Description cannot be empty.';

  @override
  String get checkAllBoxes => 'Please check all the boxes.';

  @override
  String get imageUploadFailed => 'Could not upload image, URL returned empty.';

  @override
  String get postShared => 'Post shared successfully.';

  @override
  String get newPost => 'New Post';

  @override
  String get share => 'Share';

  @override
  String get addTitle => 'Add Title';

  @override
  String get whatsHappening => 'What\'s happening?';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get consentAccuracy =>
      'I am responsible for the accuracy of the content I share.';

  @override
  String get consentRules =>
      'I commit to acting in accordance with community guidelines.';

  @override
  String get noComments => 'No comments yet. Be the first to comment!';

  @override
  String get commentHint => 'Write your comment...';

  @override
  String get filterByCity => 'Filter by City';

  @override
  String get searchCity => 'Search city...';

  @override
  String get noCityInfo => 'No city information available yet.';

  @override
  String get noCityMatch => 'No matching city found.';

  @override
  String get allOrganizations => 'All Organizations';

  @override
  String get ngosSubtitle =>
      'Discover and support non-governmental organizations';

  @override
  String get noResults => 'No results found.';

  @override
  String get ngoDetail => 'NGO Detail';

  @override
  String get civilSocietyOrg => 'Non-Governmental Organization';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get follow => 'Follow';

  @override
  String get contact => 'Contact';

  @override
  String get followers => 'Followers';

  @override
  String get tabDescription => 'Description';

  @override
  String get tabPosts => 'Posts';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get noEventsShort => 'No events yet.';

  @override
  String get noPostsShared => 'No posts shared yet.';

  @override
  String get locationUnspecified => 'Location Not Specified';

  @override
  String get statEvent => 'Events';

  @override
  String get statScore => 'Score';

  @override
  String get ourMission => 'Our Mission';

  @override
  String get ourVision => 'Our Vision';

  @override
  String get groupChatsSubtitle => 'Group chats of the events you joined';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get noActiveChats => 'No active chats yet';

  @override
  String get joinEventsForChats => 'Join events to be\npart of group chats!';

  @override
  String get discoverEvents => 'Discover Events';

  @override
  String get userInfoUnavailable => 'Could not get user information.';

  @override
  String genericErrorMessage(String message) {
    return 'An error occurred:\n$message';
  }

  @override
  String get deleteAll => 'Delete All';

  @override
  String get noNotifications => 'You have no notifications yet.';

  @override
  String get deleteAllConfirm =>
      'Are you sure you want to delete all notifications?';

  @override
  String get allNotificationsDeleted => 'All notifications deleted';

  @override
  String get volunteerAi => 'Volunteer AI';

  @override
  String get smartAssistant => 'Smart Assistant';

  @override
  String get aiGreeting => 'Hello! 👋';

  @override
  String get aiIntro =>
      'I am the GönüllüNet AI Assistant.\nI can answer your questions about Erasmus+, volunteering projects and NGOs.';

  @override
  String get quickStart => 'QUICK START';

  @override
  String get qErasmus => 'What is Erasmus+?';

  @override
  String get qHowVolunteer => 'How can I become a volunteer?';

  @override
  String get qHowJoinNgo => 'How do I join NGOs?';

  @override
  String get qNearbyEvents => 'Events near me';

  @override
  String get qNearbyEventsFull => 'What are the volunteering events near me?';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get deleteChatConfirm =>
      'This chat will be permanently deleted. Are you sure?';

  @override
  String get smartVolunteerAssistant => 'Smart Volunteering Assistant';

  @override
  String get pastChats => 'PAST CHATS';

  @override
  String get aiAssistantTitle => 'GönüllüNet AI Assistant';

  @override
  String get aiHistoryIntro =>
      'Start a new chat to get information about Erasmus+, volunteering projects, NGOs and social responsibility.';

  @override
  String get startNewChat => 'Start New Chat';

  @override
  String get askNewQuestion => 'Ask the AI assistant a new question';

  @override
  String get messageHint => 'Write a message...';

  @override
  String get noMessages => 'No messages yet.\nBe the first to send one!';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileUpdating => 'Updating profile...';

  @override
  String get profileVisibilityNote =>
      'Your profile information will be visible to the NGO that owns the event you apply for.';

  @override
  String get aboutMe => 'About Me';

  @override
  String get aboutMeHint =>
      'Introduce yourself, write your motivation and why you volunteer...';

  @override
  String get interests => 'Interests';

  @override
  String get skills => 'Skills';

  @override
  String get birthDate => 'Date of Birth';

  @override
  String get selectBirthDate => 'Select your date of birth';

  @override
  String get educationProfession => 'Education / Profession';

  @override
  String get educationHint => 'E.g. University Student, Psychology Department';

  @override
  String get locationCityDistrict => 'Location (City / District)';

  @override
  String get locationExampleHint => 'E.g. Kadıköy, Istanbul';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get ngoNameEmptyError => 'NGO name cannot be empty.';

  @override
  String get editNgoProfile => 'Edit NGO Profile';

  @override
  String get tapToChangeLogo => 'Tap to change the logo';

  @override
  String get cityExampleHint => 'Kadıköy, Istanbul';

  @override
  String get ngoDescriptionHint =>
      'Write a short description about your organization...';

  @override
  String get visionLabel => 'Vision';

  @override
  String get missionLabel => 'Mission';

  @override
  String get visionHint => 'Your vision...';

  @override
  String get missionHint => 'Your mission...';

  @override
  String get locationEmptyError => 'Location cannot be empty.';

  @override
  String get phoneEmptyError => 'Phone cannot be empty.';

  @override
  String get visionEmptyError => 'Vision cannot be empty.';

  @override
  String get missionEmptyError => 'Mission cannot be empty.';

  @override
  String get completeNgoProfileTitle => 'Complete Your Profile';

  @override
  String get completeNgoProfileNotice =>
      'You need to complete your organization profile before using the app. Fill in all the information below and save to continue.';

  @override
  String get applicantProfile => 'Applicant Profile';

  @override
  String get applicationLetter => 'Application Letter of Intent';

  @override
  String get notSpecified => 'Not specified';

  @override
  String ageLabel(Object age) {
    return '$age years';
  }

  @override
  String get errNetwork => 'Please check your internet connection.';

  @override
  String get errTimeout => 'The request timed out. Please try again.';

  @override
  String get errUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get errUnexpectedRetry =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errEmailInUse => 'This email address is already in use.';

  @override
  String get errInvalidEmailAddr => 'Invalid email address.';

  @override
  String get errWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get errWrongCredentials => 'Email or password is incorrect.';

  @override
  String get errUserNotFoundAuth => 'No account found for this email address.';

  @override
  String get errUserDisabled =>
      'This account has been disabled. Please contact support.';

  @override
  String get errTooManyAttempts =>
      'Too many failed attempts. Please wait a while.';

  @override
  String get errRequiresRecentLogin =>
      'You need to log in again for this operation.';

  @override
  String get errOperationNotAllowed =>
      'This sign-in method is not currently supported.';

  @override
  String get errExpiredActionCode =>
      'The link has expired. Please request a new one.';

  @override
  String get errInvalidActionCode => 'Invalid verification link.';

  @override
  String get errAuthGeneric => 'Authentication error. Please try again.';

  @override
  String get errPermissionDenied =>
      'You don\'t have permission for this operation.';

  @override
  String get errNotFound => 'The requested data was not found.';

  @override
  String get errAlreadyExists => 'This record already exists.';

  @override
  String get errResourceExhausted =>
      'You\'ve reached your limit or the server is too busy right now.';

  @override
  String get errCancelled => 'Operation cancelled.';

  @override
  String get errUnauthenticated =>
      'Your session has expired. Please log in again.';

  @override
  String get errFileNotFound => 'File not found.';

  @override
  String get errQuotaExceeded => 'Storage quota exceeded.';

  @override
  String get errServer => 'A server error occurred. Please try again.';

  @override
  String get errChatHistoryLoad => 'Could not load chat history.';

  @override
  String get errChatDelete => 'Could not delete chat.';

  @override
  String get errMessagesLoad => 'Could not load messages.';

  @override
  String get errLocationFailed => 'Could not get location.';

  @override
  String get errLocationNotFound => 'Location not found.';

  @override
  String get errSearchFailed => 'An error occurred during the search.';

  @override
  String get errAddressDetail => 'Address details unavailable';

  @override
  String get errUnknownLocation => 'Unknown Location';

  @override
  String get errNotificationsLoad => 'Could not load notifications.';

  @override
  String get errUserDataNotFound => 'User data not found.';

  @override
  String get errFollowFailed => 'Follow action failed.';

  @override
  String get errSignupFailed => 'An error occurred during sign up.';

  @override
  String get errEventNgoOnly =>
      'You must have an NGO account to create an event.';

  @override
  String get errEventLoginRequired =>
      'You need to log in to perform this action.';

  @override
  String get errEventFillAll => 'Please fill in all fields.';

  @override
  String get errEventProfileNotFound => 'User profile not found.';

  @override
  String get errEventCreateFailed =>
      'Could not create the event. Please try again.';

  @override
  String get errMessageSend => 'An error occurred while sending the message.';

  @override
  String get errAiDailyLimit =>
      'You\'ve reached your daily question limit. See you again tomorrow! 🚀';

  @override
  String get errAiBusy =>
      'I\'m very busy right now, could you try again in a minute? ☕';

  @override
  String get errAiTimeout =>
      'My response took a bit long, please check your internet and try again. ⏳';

  @override
  String get errAiUnreachable =>
      'The server is currently unreachable, please try again later. 🛠️';

  @override
  String get errAiOpTimeout => 'The operation timed out, please try again. ⏳';

  @override
  String get errImageUpload => 'Image upload error.';

  @override
  String get errSessionNotFound => 'User session not found.';

  @override
  String get aboutAppName => 'GönüllüNet';

  @override
  String get aboutTagline => 'Together for good';

  @override
  String get aboutDescription =>
      'GönüllüNet is a volunteering platform that brings volunteers and non-governmental organizations together. Discover events around you, apply, join group chats and make a difference with the community.';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutContactEmail => 'gonullunet@gmail.com';

  @override
  String get aboutRights => '© 2025 GönüllüNet. All rights reserved.';

  @override
  String get aboutMadeWith => 'Made with love ❤️';

  @override
  String get notifPushTitle => 'Push Notifications';

  @override
  String get notifPushSubtitle => 'Turn all notifications on or off';

  @override
  String get notifEventsTitle => 'Event Notifications';

  @override
  String get notifEventsSubtitle => 'New events and reminders';

  @override
  String get notifApplicationsTitle => 'Application Notifications';

  @override
  String get notifApplicationsSubtitle => 'Application status updates';

  @override
  String get notifMessagesTitle => 'Message Notifications';

  @override
  String get notifMessagesSubtitle => 'Group chat messages';

  @override
  String get notifAnnouncementsTitle => 'Announcements';

  @override
  String get notifAnnouncementsSubtitle => 'General announcements and news';

  @override
  String get notifSavedHint => 'Your preferences are stored on this device.';

  @override
  String changePasswordConfirm(String email) {
    return 'We\'ll send a reset link to $email. Do you want to continue?';
  }

  @override
  String get passwordResetSent =>
      'A password reset link has been sent to your email.';

  @override
  String get emailUnavailable => 'No email address was found for your account.';

  @override
  String get privacyIntro =>
      'Your privacy matters to us. This policy explains what data we collect and how we use it while you use GönüllüNet.';

  @override
  String get privacyDataTitle => 'Data We Collect';

  @override
  String get privacyDataBody =>
      'We collect the data you provide to use the app, such as your account information (name, email, profile details), the posts and events you create, and your location preferences.';

  @override
  String get privacyUsageTitle => 'Use of Data';

  @override
  String get privacyUsageBody =>
      'We use your data only to provide the service, manage event applications and improve your experience. Your data is not shared with third parties for marketing without your consent.';

  @override
  String get privacySecurityTitle => 'Security';

  @override
  String get privacySecurityBody =>
      'Your data is stored securely on Firebase infrastructure. You can delete your account at any time from within the app.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String privacyContactBody(String email) {
    return 'For privacy-related questions, you can contact us at: $email';
  }

  @override
  String get privacyLastUpdated => 'Last updated: June 2025';

  @override
  String get rateAppFailed => 'Could not open the store.';

  @override
  String get educationProfessionShort => 'Education / Profession';

  @override
  String get volunteerLevel => 'Volunteer Level';

  @override
  String get applications => 'Applications';

  @override
  String get phone => 'Phone';

  @override
  String get colApplicationStatus => 'Application Status';

  @override
  String get colApplicationDate => 'Application Date';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPending => 'Pending';

  @override
  String get excelCreateFailedException => 'Could not create Excel';

  @override
  String excelCreated(String path) {
    return 'Excel file created: $path';
  }

  @override
  String excelCreateError(String error) {
    return 'Could not create Excel: $error';
  }

  @override
  String get noApprovedApplications => 'No approved applications found.';

  @override
  String get participationListTitle => 'EVENT PARTICIPATION LIST';

  @override
  String createdDateLabel(String date) {
    return 'Created: $date';
  }

  @override
  String totalApprovedParticipants(Object count) {
    return 'Total Approved Participants: $count';
  }

  @override
  String get colFullName => 'Full Name';

  @override
  String pdfPageLabel(Object current, Object total) {
    return 'Page $current / $total';
  }

  @override
  String pdfCreateError(String error) {
    return 'Could not create PDF: $error';
  }

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get participationListPdf => 'Participation List (PDF)';

  @override
  String get noApplications => 'No applications yet.';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get noPostsOwn => 'You have no posts yet';

  @override
  String get shareFirstPost =>
      'You can share your first post using the + button on the home page.';

  @override
  String get postingNgoOnly =>
      'Sharing posts is only available for organization accounts.';

  @override
  String get editPost => 'Edit Post';

  @override
  String get titleFieldLabel => 'Title';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deletePostConfirm =>
      'Are you sure you want to delete this post? This action cannot be undone.';

  @override
  String get edit => 'Edit';

  @override
  String get levelObserver => 'Observer';

  @override
  String get levelActive => 'Active';

  @override
  String get levelPioneer => 'Pioneer';

  @override
  String get levelMaster => 'Master';

  @override
  String get levelLegend => 'Legend';
}
