<%@ page import="java.sql.*" %>
<%@ page import="memorize.NotesDBManager" %>
<%@ page import="memorize.User" %>
<%@ page import="java.util.List" %>
<%@ page import="memorize.Note" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="memorize.Utils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%! NotesDBManager notesDBManager; %>
<%!
    public void jspInit() {
        ServletContext context = getServletConfig().getServletContext();
        String databaseUrl = context.getInitParameter("databaseUrl");
        String databaseUser = context.getInitParameter("databaseUser");
        String databasePassword = context.getInitParameter("databasePassword");
        String databaseDriver = context.getInitParameter("databaseDriver");
        try {
            Class.forName(databaseDriver);  // Needed for JDK9/Tomcat9
            Connection dbConnection = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
            notesDBManager = new NotesDBManager(dbConnection);
            Utils.logger.info(this.getClass().getName() + " successfully connected to the database.");
        }
        catch (Exception e)
        {
            Utils.logger.severe(this.getClass().getName() + " failed on attempt to connect to the database.");
            e.printStackTrace();
        }
    }
%>
<%!
    public void jspDestroy() {
        notesDBManager.close();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <title>Memorize</title>
    <meta name="description" content="Learn texts by heart effectively"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="../css/libs.css">
    <link rel="stylesheet" href="../css/sign-in.css">
    <link rel="stylesheet" href="../css/workplace.css"> <!-- Resource style -->
    <script src="https://webasr.yandex.net/jsapi/v1/webspeechkit.js" type="text/javascript"></script>

    <link rel="apple-touch-icon" sizes="57x57" href="../icons/apple-icon-57x57.png">
    <link rel="apple-touch-icon" sizes="60x60" href="../icons/apple-icon-60x60.png">
    <link rel="apple-touch-icon" sizes="72x72" href="../icons/apple-icon-72x72.png">
    <link rel="apple-touch-icon" sizes="76x76" href="../icons/apple-icon-76x76.png">
    <link rel="apple-touch-icon" sizes="114x114" href="../icons/apple-icon-114x114.png">
    <link rel="apple-touch-icon" sizes="120x120" href="../icons/apple-icon-120x120.png">
    <link rel="apple-touch-icon" sizes="144x144" href="../icons/apple-icon-144x144.png">
    <link rel="apple-touch-icon" sizes="152x152" href="../icons/apple-icon-152x152.png">
    <link rel="apple-touch-icon" sizes="180x180" href="../icons/apple-icon-180x180.png">
    <link rel="icon" type="image/png" sizes="192x192"  href="../icons/android-icon-192x192.png">
    <link rel="icon" type="image/png" sizes="32x32" href="../icons/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="96x96" href="../icons/favicon-96x96.png">
    <link rel="icon" type="image/png" sizes="16x16" href="../icons/favicon-16x16.png">
    <link rel="manifest" href="../icons/manifest.json">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="msapplication-TileImage" content="../icons/ms-icon-144x144.png">
    <meta name="theme-color" content="#ffffff">
</head>
<body>
<div id="snackbar" class="mdl-js-snackbar mdl-snackbar">
    <div class="mdl-snackbar__text"></div>
    <button class="mdl-snackbar__action" type="button"></button>
</div>
<!-- Always shows a header, even in smaller screens. -->
<div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
    <header class="mdl-layout__header">
        <div class="mdl-layout__header-row">
            <!-- Title -->
            <h1 class="logo">Memorize</h1>
            <!-- Add spacer, to align navigation to the right -->
            <div class="mdl-layout-spacer"></div>
            <!-- Navigation. We hide it in small screens. -->
            <nav class="mdl-navigation">
                <!-- Right aligned menu below button -->
                <button id="demo-menu-lower-right" class="mdl-button mdl-js-button mdl-button--icon">
                    <i class="material-icons">person</i>
                </button>
                <ul class="mdl-menu mdl-menu--bottom-right mdl-js-menu mdl-js-ripple-effect"
                    for="demo-menu-lower-right">
                    <!--TODO add handlers-->
                    <li data-signin="login" class="js-signin-modal-trigger mdl-menu__item">Settings</li>
                    <a href="logout/"><li id="logout-button" class="mdl-menu__item">Log out</li></a>
                </ul>
            </nav>
        </div>
    </header>
    <div class="mdl-layout__drawer opened">
        <nav class="mdl-navigation">
            <a class="mdl-navigation__link" href="#all">
                <i class="material-icons">assignment</i>All texts
            </a>
            <a class="mdl-navigation__link" href="#inprocess">
                <i class="material-icons">access_time</i>In process
            </a>
            <a class="mdl-navigation__link" href="#learned">
                <i class="material-icons">assignment_turned_in</i>Learned
            </a>
            <!--<img src="img/learned.svg" style="height: 24px;padding-right: 32px"> in learned-->
        </nav>
    </div>
    <main class="mdl-layout__content opened">
        <button id="add-button" class="add-button mdl-button mdl-js-button mdl-button--fab mdl-js-ripple-effect mdl-button--colored">
            <i class="material-icons">&#xE145;</i>
        </button>
        <div id="all" class="page-content mdl-grid">
            <%
                User user = (User) session.getAttribute("user");
                List<Note> notes = notesDBManager.getAllNotes(user);
                List<Note> inProcess = new ArrayList<>();
                List<Note> learned = new ArrayList<>();
                for (Note note : notes)
                {
                    if (note.getProgress() == 100)
                        learned.add(note);
                    else
                        inProcess.add(note);
            %>
            <div note-id="<%=note.getId()%>" class="demo-card-event mdl-card mdl-shadow--2dp mdl-cell--12-col-phone mdl-cell--4-col-tablet mdl-cell mdl-cell--3-col">
                <div class="mdl-card__title mdl-card--expand">
                    <div class="indicator" percent="<%=note.getProgress()%>"></div>
                    <div class="shadow"></div>
                    <p text-align="<%=note.getAlign()%>"><%=note.getText()%></p>
                </div>
                <div class="mdl-card__actions mdl-card--border">
                    <a class="mdl-card__title"><%=note.getTitle()%></a>
                    <div class="mdl-layout-spacer"></div>
                    <div class="note-options">
                        <button id="a-<%=note.getId()%>" class="note-options-button mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">more_vert</i>
                        </button>
                        <ul class="mdl-menu mdl-menu--top-right mdl-js-menu" for="a-<%=note.getId()%>">
                            <%
                                if (note.getProgress() < 100)
                            {
                            %>
                            <li class="train-op mdl-menu__item">Train</li>
                            <li class="test-op mdl-menu__item">Test knowledge</li>
                            <li class="mark-op mdl-menu__item">Mark as learned</li>
                            <li class="edit-op mdl-menu__item">Edit</li>
                            <%
                            }
                            %>
                            <li class="delete-op mdl-menu__item">Delete</li>
                        </ul>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
        <div id="inprocess" class="page-content mdl-grid">
            <%
                for (Note note : inProcess) {
            %>
            <div note-id="<%=note.getId()%>" class="demo-card-event mdl-card mdl-shadow--2dp mdl-cell--12-col-phone mdl-cell--4-col-tablet mdl-cell mdl-cell--3-col">
                <div class="mdl-card__title mdl-card--expand">
                    <div class="indicator" percent="<%=note.getProgress()%>"></div>
                    <div class="shadow"></div>
                    <p text-align="<%=note.getAlign()%>"><%=note.getText()%></p>
                </div>
                <div class="mdl-card__actions mdl-card--border">
                    <a class="mdl-card__title"><%=note.getTitle()%></a>
                    <div class="mdl-layout-spacer"></div>
                    <div class="note-options">
                        <button id="p-<%=note.getId()%>" class="note-options-button mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">more_vert</i>
                        </button>
                        <ul class="mdl-menu mdl-menu--top-right mdl-js-menu" for="p-<%=note.getId()%>">
                            <li class="train-op mdl-menu__item">Train</li>
                            <li class="test-op mdl-menu__item">Test knowledge</li>
                            <li class="mark-op mdl-menu__item">Mark as learned</li>
                            <li class="edit-op mdl-menu__item">Edit</li>
                            <li class="delete-op mdl-menu__item">Delete</li>
                        </ul>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
        <div id="learned" class="page-content mdl-grid">
            <%
                for (Note note : learned) {
            %>
            <div note-id="<%=note.getId()%>" class="demo-card-event mdl-card mdl-shadow--2dp mdl-cell--12-col-phone mdl-cell--4-col-tablet mdl-cell mdl-cell--3-col">
                <div class="mdl-card__title mdl-card--expand">
                    <div class="indicator" percent="<%=note.getProgress()%>"></div>
                    <div class="shadow"></div>
                    <p text-align="<%=note.getAlign()%>"><%=note.getText()%></p>
                </div>
                <div class="mdl-card__actions mdl-card--border">
                    <a class="mdl-card__title"><%=note.getTitle()%></a>
                    <div class="mdl-layout-spacer"></div>
                    <div class="note-options">
                        <button id="l-<%=note.getId()%>" class="note-options-button mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">more_vert</i>
                        </button>
                        <ul class="mdl-menu mdl-menu--top-right mdl-js-menu" for="l-<%=note.getId()%>">
                            <li class="delete-op mdl-menu__item">Delete</li>
                        </ul>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
    </main>
    <div class="cd-view-popup js-view-popup">
        <div class="cd-view-popup__container">
            <div class="note-title">
                <input class="mdl-card__title" placeholder="Title" readonly>
                <button id="more-vert" class="mdl-button mdl-js-button mdl-button--icon">
                    <i class="material-icons">more_vert</i>
                </button>
                <div class="note-options mdl-shadow--2dp">
                    <div data-balloon="Train" data-balloon-pos="up">
                        <button id="popup-train" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">watch_later</i>
                        </button>
                    </div>
                    <div data-balloon="Test knowledge" data-balloon-pos="up">
                        <button id="popup-test" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">assignment</i>
                        </button>
                    </div>
                    <div data-balloon="Mark as learned" data-balloon-pos="up">
                        <button id="popup-mark" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">assignment_turned_in</i>
                        </button>
                    </div>
                    <div data-balloon="Edit" data-balloon-pos="up">
                        <button id="popup-edit" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">mode_edit</i>
                        </button>
                    </div>
                    <div data-balloon="Delete" data-balloon-pos="up">
                        <button id="popup-delete" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">delete</i>
                        </button>
                    </div>
                </div>
                <div class="edit-options">
                    <div data-balloon="Save" data-balloon-pos="up">
                        <button id="edit-save" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">done</i>
                        </button>
                    </div>
                    <div data-balloon="Cancel" data-balloon-pos="up">
                        <button id="edit-cancel" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">clear</i>
                        </button>
                    </div>
                    <div data-balloon="Align center" data-balloon-pos="up">
                        <button id="text-align-center" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">format_align_center</i>
                        </button>
                    </div>
                    <div data-balloon="No aligning" data-balloon-pos="up">
                        <button id="text-align-left" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">format_align_justify</i>
                        </button>
                    </div>
                    <div data-balloon="Upload file" data-balloon-pos="up" id="file-upload">
                        <button id="file-upload-btn" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">arrow_upward</i>
                        </button>
                    </div>
                </div>
                <div class="test-options">
                    <div data-balloon="Dictate" data-balloon-pos="up">
                        <button id="mic" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">mic_none</i>
                        </button>
                    </div>
                    <div data-balloon="Restart" data-balloon-pos="up">
                        <button id="test-restart" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">refresh</i>
                        </button>
                    </div>
                    <div data-balloon="Check" data-balloon-pos="up">
                        <button id="test-check" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">done</i>
                        </button>
                    </div>
                    <div data-balloon="Cancel" data-balloon-pos="up">
                        <button id="test-cancel" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">clear</i>
                        </button>
                    </div>
                </div>
                <div class="train-options">
                    <div data-balloon="Hint" data-balloon-pos="up">
                        <button id="train-hint" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">help_outline</i>
                        </button>
                    </div>
                    <div data-balloon="Cancel" data-balloon-pos="up">
                        <button id="train-cancel" class="mdl-button mdl-js-button mdl-button--icon">
                            <i class="material-icons">clear</i>
                        </button>
                    </div>
                </div>
            </div>
            <input type=file id="file-upload-input"/>
            <div class="note-text-container">
                <textarea class="mdl-textfield__input note-text" type="text" placeholder="Text" readonly></textarea>
                <div class="mdl-grid training">
                    <div class="words-container mdl-cell mdl-cell--12-col">
                        <div class="words">
                        </div>
                    </div>
                    <div class="text-container mdl-cell mdl-cell--12-col">
                        <div class="text">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="cd-signin-modal js-signin-modal">
        <div class="cd-signin-modal__container"> <!-- this is the container wrapper -->
            <ul class="cd-signin-modal__switcher js-signin-modal-switcher js-signin-modal-trigger">
                <li><a  data-signin="login" data-type="login">Password</a></li>
                <li><a  data-signin="signup" data-type="signup">Account</a></li>
            </ul>
            <div class="cd-signin-modal__block js-signin-modal-block" data-type="login">
                <form class="cd-signin-modal__form" action="changepassword/">
                    <div class="mdl-textfield mdl-js-textfield">
                        <label class="cd-signin-modal__label cd-signin-modal__label--password cd-signin-modal__label--image-replace">Password</label>
                        <input class="mdl-textfield__input" type="password" name="current" id="current" minlength="6" placeholder="Current password" checking>
                        <button type="button" class="mdl-button mdl-js-button mdl-button--icon visibility js-hide-password">
                            <i class="material-icons">visibility</i>
                            <i class="material-icons">visibility_off</i>
                        </button>
                        <label class="mdl-textfield__label" for="current"></label>
                        <span class="mdl-textfield__error">Password is too short</span>
                    </div>
                    <div class="mdl-textfield mdl-js-textfield">
                        <label class="cd-signin-modal__label cd-signin-modal__label--password cd-signin-modal__label--image-replace">Password</label>
                        <input class="mdl-textfield__input" type="password" name="new" id="new" minlength="6" placeholder="New password" checking>
                        <button type="button" class="mdl-button mdl-js-button mdl-button--icon visibility js-hide-password">
                            <i class="material-icons">visibility</i>
                            <i class="material-icons">visibility_off</i>
                        </button>
                        <label class="mdl-textfield__label" for="new"></label>
                        <span class="mdl-textfield__error">Password is too short</span>
                    </div>
                    <div class="submit-buttons">
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" type="ajax-submit">
                            Change password
                        </button>
                    </div>
                    <div class="submit-buttons">
                        <button type="button" data-signin="reset" class="js-signin-modal-trigger mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect">
                            I forgot password
                        </button>
                    </div>
                </form>
            </div>

            <div class="cd-signin-modal__block js-signin-modal-block" data-type="signup"> <!-- sign up form -->
                <p class="cd-signin-modal__message">Deleting your account is an action you can't cancel. Think twice.</p>
                <form class="cd-signin-modal__form" action="../deleteaccount/">
                    <div class="mdl-textfield mdl-js-textfield">
                        <label class="cd-signin-modal__label cd-signin-modal__label--password cd-signin-modal__label--image-replace">Password</label>
                        <input class="mdl-textfield__input" type="password" name="password" minlength="6" placeholder="Password" checking>
                        <button type="button" class="mdl-button mdl-js-button mdl-button--icon visibility js-hide-password">
                            <i class="material-icons">visibility</i>
                            <i class="material-icons">visibility_off</i>
                        </button>
                        <label class="mdl-textfield__label"></label>
                        <span class="mdl-textfield__error">Password is too short</span>
                    </div>
                    <div class="submit-buttons">
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" type="delete-account-submit">
                            Delete account
                        </button>
                    </div>
                </form>
            </div>

            <div class="cd-signin-modal__block js-signin-modal-block" data-type="reset"> <!-- reset password form -->
                <button data-signin="login" class="js-signin-modal-trigger back mdl-button mdl-js-button mdl-button--icon">
                    <i class="material-icons">arrow_back</i>
                </button>
                <p class="cd-signin-modal__message">Lost your password? Please enter your email address. You will receive a link to create a new password.</p>
                <form class="cd-signin-modal__form" action="../recoverpassword/">
                    <div class="mdl-textfield mdl-js-textfield">
                        <label class="cd-signin-modal__label cd-signin-modal__label--email cd-signin-modal__label--image-replace" for="login">E-mail</label>
                        <input class="mdl-textfield__input" type="email" name="login" id="login" placeholder="Email" checking>
                        <label class="mdl-textfield__label" for="login"></label>
                        <span class="mdl-textfield__error">Email is not valid</span>
                    </div>
                    <div class="submit-buttons">
                        <button class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" type="ajax-submit">
                            Reset password
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="../js/libs.min.js" type="text/javascript"></script>
<script src="../js/difflib.js" type="text/javascript"></script>
<script src="../js/workplace.js" type="text/javascript"></script>
<script src="../js/sign-in.js" type="text/javascript"></script>
<script src="../js/form-submit.js" type="text/javascript"></script>
</body>
</html>