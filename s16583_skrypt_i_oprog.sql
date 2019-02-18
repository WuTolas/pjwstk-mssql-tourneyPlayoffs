If DB_ID(N's16583') IS NULL
	CREATE DATABASE s16583;
GO

If DB_ID(N's16583') IS NOT NULL
	USE s16583;
GO

IF OBJECT_ID('team_plays_tourney') IS NOT NULL
	DROP TABLE team_plays_tourney;
GO

IF OBJECT_ID('player_plays_match') IS NOT NULL
	DROP TABLE player_plays_match;
GO

IF OBJECT_ID('match_status') IS NOT NULL
	DROP TABLE match_status;
GO

IF OBJECT_ID('match_map') IS NOT NULL
	DROP TABLE match_map;
GO

IF OBJECT_ID('tourney_match') IS NOT NULL
	DROP TABLE tourney_match;
GO

IF OBJECT_ID('tourney_status') IS NOT NULL
	DROP TABLE tourney_status;
GO

IF OBJECT_ID('event_status') IS NOT NULL
	DROP TABLE event_status;
GO

IF OBJECT_ID('tourney') IS NOT NULL
	DROP TABLE tourney;
GO

IF OBJECT_ID('tourney_setting') IS NOT NULL
	DROP TABLE tourney_setting;
GO

IF OBJECT_ID('match_format') IS NOT NULL
	DROP TABLE match_format;
GO

IF OBJECT_ID('teams_limit') IS NOT NULL
	DROP TABLE teams_limit;
GO

IF OBJECT_ID('team_log') IS NOT NULL
	DROP TABLE team_log;
GO

IF OBJECT_ID('team_action') IS NOT NULL
	DROP TABLE team_action;
GO

IF OBJECT_ID('map') IS NOT NULL
	DROP TABLE map;
GO

IF OBJECT_ID('player_in_team') IS NOT NULL
	DROP TABLE player_in_team;
GO

IF OBJECT_ID('team') IS NOT NULL
	DROP TABLE team;
GO

IF OBJECT_ID('game') IS NOT NULL
	DROP TABLE game;
GO

IF OBJECT_ID('player') IS NOT NULL
	DROP TABLE player;
GO

IF OBJECT_ID('nationality') IS NOT NULL
	DROP TABLE nationality;
GO

IF OBJECT_ID('title') IS NOT NULL
	DROP TABLE title;
GO

IF OBJECT_ID('title_type') IS NOT NULL
	DROP TABLE title_type;
GO

IF OBJECT_ID('matchFormatIsCorrect') IS NOT NULL
	DROP FUNCTION dbo.matchFormatIsCorrect;
GO

IF OBJECT_ID('generateTeamLogAction') IS NOT NULL
	DROP FUNCTION dbo.generateTeamLogAction;
GO

IF OBJECT_ID('validateTitle') IS NOT NULL
	DROP FUNCTION dbo.validateTitle;
GO

IF OBJECT_ID('getTeamsLimitAndNumber') IS NOT NULL
	DROP PROCEDURE dbo.getTeamsLimitAndNumber;
GO

IF OBJECT_ID('checkTeamsLimitStatus') IS NOT NULL
	DROP FUNCTION dbo.checkTeamsLimitStatus;
GO

IF OBJECT_ID('generateTournamentSeeds') IS NOT NULL
	DROP PROCEDURE dbo.generateTournamentSeeds;
GO

IF OBJECT_ID('getRequiredPlayersNumberInTeam') IS NOT NULL
	DROP FUNCTION dbo.getRequiredPlayersNumberInTeam;
GO

IF OBJECT_ID('countPlayersInTeam') IS NOT NULL
	DROP FUNCTION dbo.countPlayersInTeam;
GO

IF OBJECT_ID('generateTournamentTree') IS NOT NULL
	DROP PROCEDURE dbo.generateTournamentTree;
GO

IF OBJECT_ID('checkTeamMatchesNumberInTourney') IS NOT NULL
	DROP FUNCTION dbo.checkTeamMatchesNumberInTourney;
GO

IF OBJECT_ID('checkForBothScores') IS NOT NULL
	DROP FUNCTION dbo.checkForBothScores;
GO

IF OBJECT_ID('checkWinner') IS NOT NULL
	DROP FUNCTION dbo.checkWinner;
GO

IF OBJECT_ID('checkLoser') IS NOT NULL
	DROP FUNCTION dbo.checkLoser;
GO

IF OBJECT_ID('generateSeedHelper') IS NOT NULL
	DROP PROCEDURE dbo.generateSeedHelper;
GO

IF OBJECT_ID('insertWinner') IS NOT NULL
	DROP PROCEDURE dbo.insertWinner;
GO

IF OBJECT_ID('getNextGameNumber') IS NOT NULL
	DROP FUNCTION dbo.getNextGameNumber;
GO

IF OBJECT_ID('insertDropoutPlacement') IS NOT NULL
	DROP PROCEDURE dbo.insertDropoutPlacement;
GO

IF OBJECT_ID('getTeamPlacement') IS NOT NULL
	DROP FUNCTION dbo.getTeamPlacement;
GO

IF OBJECT_ID('getLoserId') IS NOT NULL
	DROP FUNCTION dbo.getLoserId;
GO

IF OBJECT_ID('seedHelper') IS NOT NULL
	DROP PROCEDURE dbo.seedHelper;
GO

IF OBJECT_ID('seedInserter') IS NOT NULL
	DROP PROCEDURE dbo.seedInserter;
GO

IF OBJECT_ID('insertPlayersInMatch') IS NOT NULL
	DROP PROCEDURE dbo.insertPlayersInMatch;
GO

IF TYPE_ID('seedTable') IS NOT NULL
	DROP TYPE dbo.seedTable;
GO

IF OBJECT_ID('playedMostMatches') IS NOT NULL
	DROP VIEW dbo.playedMostMatches;
GO

IF OBJECT_ID('victoriesInTournamentAsCaptain') IS NOT NULL
	DROP VIEW dbo.victoriesInTournamentAsCaptain;
GO

IF OBJECT_ID('roadToFinal') IS NOT NULL
	DROP PROCEDURE dbo.roadToFinal;
GO

IF OBJECT_ID('getMatchScore') IS NOT NULL
	DROP PROCEDURE dbo.getMatchScore;
GO

IF OBJECT_ID('getTourneyLadder') IS NOT NULL
	DROP PROCEDURE dbo.getTourneyLadder;
GO

CREATE TYPE seedTable AS TABLE (
	id INT IDENTITY PRIMARY KEY,
	seed1 INT, 
	seed2 INT
);
GO

CREATE TABLE title_type (
	id INT IDENTITY PRIMARY KEY,
	type_name VARCHAR(20) NOT NULL UNIQUE
);
GO

CREATE TABLE title (
	id INT IDENTITY PRIMARY KEY,
	id_title_type INT NOT NULL FOREIGN KEY REFERENCES title_type(id),
	title_name VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE game (
	id INT IDENTITY PRIMARY KEY,
	game_name VARCHAR(60) NOT NULL UNIQUE
);
GO

CREATE TABLE map (
	id INT IDENTITY PRIMARY KEY,
	id_game INT NOT NULL FOREIGN KEY REFERENCES game(id),
	map_name VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE nationality (
	id INT IDENTITY PRIMARY KEY,
	nationality_name VARCHAR(60) NOT NULL UNIQUE,
	shortcut CHAR(2) NOT NULL UNIQUE CHECK(UPPER(shortcut) = shortcut AND LEN(shortcut) = 2)
);
GO

CREATE TABLE team (
	id INT IDENTITY PRIMARY KEY,
	id_nationality INT NOT NULL FOREIGN KEY REFERENCES nationality(id),
	id_game INT NOT NULL FOREIGN KEY REFERENCES game(id),
	team_name VARCHAR(60) NOT NULL UNIQUE CHECK(LEN(team_name) >= 2),
	creation_date DATE NOT NULL DEFAULT GETDATE()
);
GO

CREATE FUNCTION validateTitle(@idTitle INT, @idType INT)
	RETURNS BIT
AS
BEGIN
	DECLARE @boolean BIT; -- 1 as true, 0 as false
	DECLARE @count INT;

	SELECT @count = COUNT(t.id)
	FROM title t
	INNER JOIN title_type tt
		ON t.id_title_type = tt.id
	WHERE t.id = @idTitle AND tt.id = @idType;

	IF (@count = 0)
		SET @boolean = 0; -- Title doesn't exist in provided type
	ELSE 
		SET @boolean = 1; -- Title exists in provided type

	RETURN @boolean;
END;
GO

CREATE TABLE player (
	id INT IDENTITY PRIMARY KEY,
	id_title INT NOT NULL FOREIGN KEY REFERENCES title(id) CHECK(dbo.validateTitle(id_title, 2) = 1), -- 2 in function parameters is for Site titles
	id_nationality INT NOT NULL FOREIGN KEY REFERENCES nationality(id),
	nick_name VARCHAR(20) NOT NULL UNIQUE CHECK(LEN(nick_name) >= 2),
	first_name VARCHAR(30) NULL,
	last_name VARCHAR(40) NULL,
	gender CHAR(1) NULL CHECK(Gender = 'M' OR Gender = 'F'),
	register_date DATE NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE player_in_team (
	id_player INT NOT NULL FOREIGN KEY REFERENCES player(id),
	id_team INT NOT NULL FOREIGN KEY REFERENCES team(id),
	id_title INT NOT NULL FOREIGN KEY REFERENCES title(id) DEFAULT 1 CHECK(dbo.validateTitle(id_title, 1) = 1), -- 1 in function parameters is for Team titles
	UNIQUE(id_player, id_team)
);
GO

CREATE TABLE team_action (
	id INT IDENTITY PRIMARY KEY,
	action_name VARCHAR(20) UNIQUE CHECK(LEN(action_name) > 2)
);
GO

CREATE TABLE team_log (
	id_player INT NOT NULL FOREIGN KEY REFERENCES player(id),
	id_team INT NOT NULL FOREIGN KEY REFERENCES team(id),
	id_team_action INT NOT NULL FOREIGN KEY REFERENCES team_action(id),
	log_date DATETIME NOT NULL DEFAULT GETDATE() 
);
GO

CREATE FUNCTION matchFormatIsCorrect(
	@format VARCHAR(6)
)
	RETURNS BIT
AS
BEGIN 
	DECLARE @result BIT
	SET @result = 0;

	IF (@format LIKE '%vs%')
	BEGIN
		DECLARE @length INT;
		SET @length = LEN(@format);

		IF (@length = 4 AND ISNUMERIC(LEFT(@format, 1)) = 1 AND ISNUMERIC(RIGHT(@format, 1)) = 1 AND LEFT(@format, 1) = RIGHT(@format, 1) )
			SET @result = 1;
		ELSE IF (@length = 6 AND ISNUMERIC(LEFT(@format, 2)) = 1 AND ISNUMERIC(RIGHT(@format, 2)) = 1 AND LEFT(@format, 2) = RIGHT(@format, 2) )
			SET @result = 1;
	END

	RETURN @result;
END;
GO

CREATE TABLE match_format (
	id INT IDENTITY PRIMARY KEY,
	match_format VARCHAR(6) NOT NULL UNIQUE CHECK( (LEN(match_format) = 4 OR LEN(match_format) = 6) AND dbo.matchFormatIsCorrect(match_format) = 1)
);
GO

CREATE TABLE teams_limit (
	id INT IDENTITY PRIMARY KEY,
	max_teams INT NOT NULL UNIQUE CHECK( LOG(max_teams, 2) = ROUND(LOG(max_teams, 2), 0) AND max_teams > 2 )
	/* Only power of 2 are allowed in max_teams field */
);
GO

CREATE TABLE tourney_setting (
	id INT IDENTITY PRIMARY KEY,
	id_game INT NOT NULL FOREIGN KEY REFERENCES game(id),
	id_teams_limit INT NOT NULL FOREIGN KEY REFERENCES teams_limit(id),
	id_match_format INT NOT NULL FOREIGN KEY REFERENCES match_format(id),
	UNIQUE(id_game, id_teams_limit, id_match_format)
);
GO

CREATE TABLE event_status (
	id INT IDENTITY PRIMARY KEY,
	status_name VARCHAR(20) NOT NULL UNIQUE CHECK(LEN(status_name) > 3)
);
GO

CREATE TABLE tourney (
	id INT IDENTITY PRIMARY KEY,
	id_created_by INT NOT NULL FOREIGN KEY REFERENCES player(id),
	id_tourney_setting INT NULL FOREIGN KEY REFERENCES tourney_setting(id),
	tourney_name VARCHAR(60) NOT NULL UNIQUE CHECK(LEN(tourney_name) > 3),
	creation_date DATETIME NOT NULL DEFAULT GETDATE(),
	start_date DATE NULL
);
GO

CREATE TABLE tourney_status (
	id_tourney INT NOT NULL FOREIGN KEY REFERENCES tourney(id),
	id_event_status INT NOT NULL FOREIGN KEY REFERENCES event_status(id),
	change_date DATETIME NOT NULL DEFAULT GETDATE(),
	UNIQUE(id_tourney, id_event_status)
);
GO

CREATE TABLE team_plays_tourney (
	id_tourney INT NOT NULL FOREIGN KEY REFERENCES tourney(id),
	id_team INT NOT NULL FOREIGN KEY REFERENCES team(id),
	team_seed INT NULL,
	team_final_standing VARCHAR(9) NULL,
	UNIQUE(id_tourney, id_team)
);
GO

CREATE TABLE tourney_match (
	id INT IDENTITY PRIMARY KEY,
	id_team1 INT NULL FOREIGN KEY REFERENCES team(id),
	id_team2 INT NULL FOREIGN KEY REFERENCES team(id),
	id_tourney INT NOT NULL FOREIGN KEY REFERENCES tourney(id),
	game_number INT NOT NULL,
	tourney_round TINYINT NOT NULL,
	match_date DATETIME NULL
);
GO

CREATE TABLE match_status (
	id_tourney_match INT NOT NULL FOREIGN KEY REFERENCES tourney_match(id),
	id_event_status INT NOT NULL FOREIGN KEY REFERENCES event_status(id),
	change_date DATETIME NOT NULL DEFAULT GETDATE(),
	UNIQUE(id_tourney_match, id_event_status)
);
GO

CREATE TABLE match_map (
	id_tourney_match INT NOT NULL FOREIGN KEY REFERENCES tourney_match(id),
	id_map INT NOT NULL FOREIGN KEY REFERENCES map(id),
	id_team INT NOT NULL FOREIGN KEY REFERENCES team(id),
	map_score TINYINT NOT NULL,
	UNIQUE(id_tourney_match, id_map, id_team)
);
GO

CREATE TABLE player_plays_match (
	id_player INT NOT NULL FOREIGN KEY REFERENCES player(id),
	id_tourney_match INT NOT NULL FOREIGN KEY REFERENCES tourney_match(id),
	id_team INT NOT NULL FOREIGN KEY REFERENCES team(id),
	UNIQUE(id_player, id_tourney_match, id_team)
);
GO

INSERT INTO title_type (type_name) 
VALUES
	('Team'),
	('Site');
GO

INSERT INTO title (title_name, id_title_type)
VALUES
	('Active player', 1),
	('Captain', 1),
	('Inactive player', 1),
	('Backup player', 1),
	('Honorary player', 1),
	('Normal user', 2),
	('Administrator', 2),
	('Moderator', 2);
GO

INSERT INTO nationality (nationality_name, shortcut)
VALUES
	('Argentina', 'AR'),
	('Austria', 'AT'),
	('Belgium', 'BE'),
	('Belarus', 'BY'),
	('Brazil', 'BR'),
	('Bulgaria', 'BG'),
	('Canada', 'CA'),
	('Chile', 'CL'),
	('China', 'CN'),
	('Croatia', 'HR'),
	('Czech Republic', 'CZ'),
	('Denmark', 'DK'),
	('Estionia', 'EE'),
	('Finland', 'FI'),
	('France', 'FR'),
	('Germany', 'DE'),
	('Hungary', 'HU'),
	('Iceland', 'IS'),
	('Ireland', 'IE'),
	('Israel', 'IL'),
	('Italy', 'IT'),
	('Japan', 'JP'),
	('Latvia', 'LV'),
	('Malta', 'MT'),
	('Netherlands', 'NL'),
	('Norway', 'NO'),
	('Poland', 'PL'),
	('Portugal', 'PT'),
	('Slovakia', 'SK'),
	('Spain', 'ES'),
	('Sweden', 'SE'),
	('Switzerland', 'CH'),
	('Turkey', 'TR'),
	('Ukraine', 'UA'),
	('United Kingdom', 'GB'),
	('United States', 'US'),
	('Europe', 'EU');
GO

INSERT INTO game (game_name)
VALUES
	('Wolfenstein: Enemy Territory'),
	('Return to Castle Wolfenstein'),
	('Counter Strike: Global Offensive'),
	('League Of Legends'),
	('DOTA2');
GO

INSERT INTO map (id_game, map_name)
VALUES
	(1, 'Supply'),
	(1, 'Sw_Goldrush_te'),
	(1, 'Sp_Delivery_te'),
	(1, 'Bremen_b3'),
	(1, 'Braundorf_b4'),
	(1, 'Frostbite'),
	(1, 'Adlernest'),
	(3, 'Inferno'),
	(3, 'Train'),
	(3, 'Mirage'),
	(3, 'Nuke'),
	(3, 'Overpass'),
	(3, 'Cache'),
	(3, 'Cobblestone'),
	(4, 'Summoners Rift'),
	(4, 'Twisted Treeline'),
	(4, 'Howling Abyss');
GO

INSERT INTO event_status (status_name)
VALUES
	('Created'),
	('Finished'),
	('Cancelled'),
	('Postponed');
GO

INSERT INTO team_action (action_name)
VALUES
	('Created team'),
	('Joined team'),
	('Left team'),
	('Set as Active'),
	('Set as Captain'),
	('Set as Inactive'),
	('Set as Backup'),
	('Set as Honorary');
GO

INSERT INTO player (id_title, id_nationality, nick_name, first_name, last_name, gender, register_date)
VALUES
	(7, 27, 'WuT', 'Damian', 'Rutkowski', 'M', '2010-01-01'),
	(6, 27, 'BloOdje', '£ukasz', 'Rusielewicz', 'M', '2010-01-01'),
	(6, 27, 'dialer', 'Patryk', 'Karolewski', 'M', '2010-01-01'),
	(6, 27, 'wiaderko', 'Micha³', 'Waszak', 'M', '2010-01-01'),
	(6, 27, 'h2o', 'Micha³', 'Babiñski', 'M', '2010-01-01'),
	(6, 27, 'Abj', 'Piotr', 'Krupa', 'M', '2010-01-01'),
	(6, 16, 'w1Za', NULL, NULL, 'M', '2010-01-01'),
	(6, 16, 'psiquh', NULL, NULL, 'M', '2010-01-01'),
	(6, 16, 'ScaTmaN_', NULL, NULL, 'M', '2010-01-01'),
	(6, 16, 'mKs', NULL, NULL, 'M', '2010-01-01'),
	(6, 16, 'FimS', NULL, NULL, 'M', '2010-01-01'),
	(6, 31, 'Ekto', NULL, NULL, 'M', '2010-01-01'),
	(6, 16, 'Bl4d3', NULL, NULL, 'M', '2010-01-02'),
	(6, 16, 'FloPJEHZ', NULL, NULL, 'M', '2010-01-02'),
	(6, 33, 'FiREBALL', NULL, NULL, 'M', '2010-01-02'),
	(6, 16, 'kReSti', NULL, NULL, 'M', '2010-01-02'),
	(6, 16, 'stRay', NULL, NULL, 'M', '2010-01-02'),
	(6, 16, 'stownage', NULL, NULL, 'M', '2010-01-02'),
	(6, 16, 'Cobra', NULL, NULL, 'M', '2010-01-03'),
	(6, 16, 'Funi', NULL, NULL, 'M', '2010-01-03'),
	(6, 16, 'chosen', NULL, NULL, 'M', '2010-01-03'),
	(6, 16, 'zero', NULL, NULL, 'M', '2010-01-03'),
	(6, 14, 'lEku', NULL, NULL, 'M', '2010-01-03'),
	(6, 16, 'laNgo', NULL, NULL, 'M', '2010-01-03'),
	(6, 25, 'Sebhes', NULL, NULL, 'M', '2010-01-04'),
	(6, 25, 'hayaa', NULL, NULL, 'M', '2010-01-04'),
	(6, 25, 'iNsAne', NULL, NULL, 'M', '2010-01-04'),
	(6, 25, 'GiZmOoO', NULL, NULL, 'M', '2010-01-04'),
	(6, 25, 'outlAw', NULL, NULL, 'M', '2010-01-04'),
	(6, 3, 'Jere', NULL, NULL, 'M', '2010-01-04'),
	(6, 16, 'Ava', NULL, NULL, 'M', '2010-01-05'),
	(6, 16, 'suuhk', NULL, NULL, 'M', '2010-01-05'),
	(6, 16, 'Specula', NULL, NULL, 'M', '2010-01-05'),
	(6, 32, 'Aq', NULL, NULL, 'M', '2010-01-05'),
	(6, 25, 'Testi', NULL, NULL, 'M', '2010-01-05'),
	(6, 35, 'ScarZy', NULL, NULL, 'M', '2010-01-05'),
	(6, 25, 'Freddy', NULL, NULL, 'M', '2010-01-06'),
	(6, 25, 'Woott', NULL, NULL, 'F', '2010-01-06'),
	(6, 14, 'smak', NULL, NULL, 'M', '2010-01-06'),
	(6, 14, 'Rsp', NULL, NULL, 'M', '2010-01-06'),
	(6, 14, 'tomba', NULL, NULL, 'M', '2010-01-06'),
	(6, 14, 'poksuu', NULL, NULL, 'M', '2010-01-06'),
	(6, 25, 'kApot', NULL, NULL, 'M', '2010-01-07'),
	(6, 25, 'shjzn', NULL, NULL, 'M', '2010-01-07'),
	(6, 25, 'timbolina', NULL, NULL, 'M', '2010-01-07'),
	(6, 14, 'Sherclock', NULL, NULL, 'M', '2010-01-07'),
	(6, 35, 'Shaman', NULL, NULL, 'M', '2010-01-07'),
	(6, 35, 'Fanta', NULL, NULL, 'M', '2010-01-07'),
	(6, 36, 'ohurcool', NULL, NULL, 'M', '2010-01-08'),
	(6, 36, 'ipod', NULL, NULL, 'M', '2010-01-08'),
	(6, 31, 'Tites', NULL, NULL, 'M', '2010-01-08'),
	(6, 16, 'eujen', NULL, NULL, 'M', '2010-01-08'),
	(6, 25, 'kARMA', NULL, NULL, 'M', '2010-01-08'),
	(6, 25, 'mEnace', NULL, NULL, 'M', '2010-01-08'),
	(6, 3, 'PlAyer', NULL, NULL, 'M', '2010-01-09'),
	(6, 3, 'vila', NULL, NULL, 'M', '2010-01-09'),
	(6, 3, 'mesq', NULL, NULL, 'M', '2010-01-09'),
	(6, 3, 'lio', NULL, NULL, 'M', '2010-01-09'),
	(6, 14, 'toNy', NULL, NULL, 'M', '2010-01-09'),
	(6, 14, 'Swanidius', NULL, NULL, 'M', '2010-01-09'),
	(6, 25, 'aphesia', NULL, NULL, 'M', '2010-01-10'),
	(6, 25, 'Ronner', NULL, NULL, 'M', '2010-01-10'),
	(6, 3, 'homiee', NULL, NULL, 'M', '2010-01-10'),
	(6, 13, 'Night', NULL, NULL, 'M', '2010-01-10'),
	(6, 35, 'crumbs', NULL, NULL, 'M', '2010-01-10'),
	(6, 35, 'Artstar', NULL, NULL, 'M', '2010-01-10'),
	(6, 35, 'Williams', NULL, NULL, 'M', '2010-01-11'),
	(6, 16, 'meNtal', NULL, NULL, 'M', '2010-01-11'),
	(6, 27, 'samraj', NULL, NULL, 'M', '2010-01-11'),
	(6, 13, 'couchor', NULL, NULL, 'M', '2010-01-11'),
	(6, 11, 'veruna', NULL, NULL, 'M', '2010-01-11'),
	(6, 11, 'Kimi', NULL, NULL, 'M', '2010-01-11'),
	(6, 3, 'chry', NULL, NULL, 'M', '2010-01-12'),
	(6, 3, 'mAus', NULL, NULL, 'M', '2010-01-12'),
	(6, 35, 'sqzz', NULL, NULL, 'M', '2010-01-12'),
	(6, 35, 'R0SS', NULL, NULL, 'M', '2010-01-12'),
	(6, 14, 'Matias', NULL, NULL, 'M', '2010-01-12'),
	(6, 21, 'XyLoS', NULL, NULL, 'M', '2010-01-12'),
	(6, 35, 'mini', NULL, NULL, 'M', '2010-01-14'),
	(6, 11, 'cpu', NULL, NULL, 'M', '2010-01-15'),
	(6, 11, 'denton', NULL, NULL, 'M', '2010-01-15'),
	(6, 11, 'Green_clon', NULL, NULL, 'M', '2010-01-15'),
	(6, 11, 'Loocko', NULL, NULL, 'M', '2010-01-15'),
	(6, 11, 'Rifleman', NULL, NULL, 'M', '2010-01-15'),
	(6, 11, 'Malfoy', NULL, NULL, 'M', '2010-01-15'),
	(6, 27, 'brAhi', NULL, NULL, 'M', '2010-01-16'),
	(6, 27, 'staminaboy', NULL, NULL, 'M', '2010-01-16'),
	(6, 27, 'termit', NULL, NULL, 'M', '2010-01-16'),
	(6, 27, 'wiesiek', NULL, NULL, 'M', '2010-01-16'),
	(6, 27, 'znajda', NULL, NULL, 'M', '2010-01-16'),
	(6, 27, 'wolfplayer', NULL, NULL, 'M', '2010-01-16'),
	(6, 25, 'dEzz', NULL, NULL, 'M', '2010-01-17'),
	(6, 25, 'Trixor', NULL, NULL, 'M', '2010-01-17'),
	(6, 25, 'artifexx', NULL, NULL, 'M', '2010-01-17'),
	(6, 3, 'jetro', NULL, NULL, 'M', '2010-01-17'),
	(6, 3, 'zeto', NULL, NULL, 'M', '2010-01-17'),
	(6, 3, 'bobax', NULL, NULL, 'M', '2010-01-17');
GO

INSERT INTO team (id_nationality, id_game, team_name, creation_date)
VALUES
	(37, 1, 'CatiNaHat', '2010-02-01'),
	(37, 1, 'Elysium', '2010-02-01'),
	(37, 1, 'Get face or muscles', '2010-02-01'),
	(16, 1, 'Teamoxid silver', '2010-02-01'),
	(16, 1, 'SMASHED', '2010-02-01'),
	(27, 1, 'Team Solo B', '2010-02-01'),
	(37, 1, 'xD Trickjump', '2010-02-01'),
	(36, 1, 'Eurocans', '2010-02-01'),
	(16, 1, 'Teamoxid6', '2010-02-01'),
	(37, 1, 'Paronix', '2010-02-01'),
	(37, 1, 'randomZ', '2010-02-01'),
	(37, 1, 'TheMoneyTeam', '2010-02-01'),
	(37, 1, 'k1ngs', '2010-02-01'),
	(11, 1, 'inteReaction', '2010-02-01'),
	(27, 1, 'orzel7', '2010-02-01'),
	(25, 1, 'vital', '2010-02-01'),
	(14, 1, 'Kurwittu', '2010-02-03'),
	(37, 1, 'bSTURZ', '2010-02-03'),
	(37, 1, '3 Amigos', '2010-02-03'),
	(25, 1, 'viSual', '2010-02-03'),
	(16, 1, 'Teamoxid3', '2010-02-03'),
	(36, 1, 'rektem', '2010-02-03'),
	(27, 1, 'b2k', '2010-02-03'),
	(37, 1, 'Gut Lack', '2010-02-03');
GO

INSERT INTO teams_limit (max_teams)
VALUES
	(4),
	(8),
	(16),
	(32),
	(64),
	(128),
	(256);
GO

INSERT INTO match_format (match_format)
VALUES
	('1vs1'),
	('2vs2'),
	('3vs3'),
	('4vs4'),
	('5vs5'),
	('6vs6'),
	('10vs10'),
	('12vs12');
GO

INSERT INTO tourney_setting (id_game, id_teams_limit, id_match_format)
VALUES
	(1, 1, 3), -- W:ET, 4 teams, 3vs3
	(1, 1, 6), -- W:ET, 4 teams, 6vs6
	(1, 2, 3), -- W:ET, 8 teams, 3vs3
	(1, 3, 6), -- W:ET, 16 teams, 6vs6
	(1, 3, 3), -- W:ET, 16 teams, 3vs3
	(1, 3, 5); -- W:ET, 16 teams, 5vs5
GO

CREATE FUNCTION generateTeamLogAction (
	@type VARCHAR(6),
	@idTeam INT,
	@idTitle INT
)
RETURNS INT
AS
BEGIN
	DECLARE @idTeamAction INT;

	IF @type = 'insert'
	BEGIN
		DECLARE @membersInTeam INT;

		SELECT @membersInTeam = COUNT(id_player)
		FROM player_in_team
		WHERE id_team = @idTeam;

		IF (@membersInTeam = 1)
			SET @idTeamAction = 1; -- Player created team
		ELSE
			SET @idTeamAction = 2; -- Player joined team
	END;
	ELSE IF (@type = 'update')
	BEGIN
		DECLARE @titleSwitch INT;

		SELECT @titleSwitch = CASE @idTitle
			WHEN 1 THEN 4 -- Set as Active
			WHEN 2 THEN 5 -- Set as Captain
			WHEN 3 THEN 6 -- Set as Inactive
			WHEN 4 THEN 7 -- Set as Backup
			WHEN 5 THEN 8 -- Set as Honorary
		END

		SET @idTeamAction = @titleSwitch; 
	END;
	ELSE IF (@type = 'delete')
		SET @idTeamAction = 3; -- Player left team

	RETURN @idTeamAction;
END;
GO

CREATE TRIGGER insertTeamLog
ON player_in_team
	AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @type VARCHAR(6);
	DECLARE @id_player INT;
	DECLARE @id_team INT;
	DECLARE @id_title INT;
	DECLARE @id_team_action INT;
	DECLARE @log_date DATETIME;

	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
		SET @type = 'insert';

	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		SET @type = 'update';

	IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		SET @type = 'delete';
		SELECT @id_player = id_player FROM deleted;
		SELECT @id_team = id_team FROM deleted;
		SELECT @id_title = id_title FROM deleted;
	END
	ELSE
	BEGIN
		SELECT @id_player = id_player FROM inserted;
		SELECT @id_team = id_team FROM inserted;
		SELECT @id_title = id_title FROM inserted;
	END;

		SET @id_team_action = dbo.generateTeamLogAction(@type, @id_team, @id_title);
		SET @log_date = GETDATE();
	
		INSERT INTO team_log (id_player, id_team, id_team_action, log_date)
		VALUES (@id_player, @id_team, @id_team_action, @log_date);
END;
GO

INSERT INTO player_in_team (id_player, id_team) VALUES (1, 6);
INSERT INTO player_in_team (id_player, id_team) VALUES (2, 6);
INSERT INTO player_in_team (id_player, id_team) VALUES (3, 6);
INSERT INTO player_in_team (id_player, id_team) VALUES (4, 6);
INSERT INTO player_in_team (id_player, id_team) VALUES (5, 6);
INSERT INTO player_in_team (id_player, id_team) VALUES (6, 6);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 1 AND id_team = 6;
UPDATE player_in_team SET id_title = 3 WHERE id_player = 2 AND id_team = 6;
DELETE FROM player_in_team WHERE id_player = 4 AND id_team = 6;
INSERT INTO player_in_team (id_player, id_team) VALUES (4, 6);
UPDATE player_in_team SET id_title = 4 WHERE id_player = 3 AND id_team = 6;
UPDATE player_in_team SET id_title = 1 WHERE id_player = 3 AND id_team = 6;
INSERT INTO player_in_team (id_player, id_team) VALUES (7, 5);
INSERT INTO player_in_team (id_player, id_team) VALUES (8, 5);
INSERT INTO player_in_team (id_player, id_team) VALUES (9, 5);
INSERT INTO player_in_team (id_player, id_team) VALUES (10, 5);
INSERT INTO player_in_team (id_player, id_team) VALUES (11, 5);
INSERT INTO player_in_team (id_player, id_team) VALUES (12, 5);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 7 AND id_team = 5;
INSERT INTO player_in_team (id_player, id_team) VALUES (13, 9);
INSERT INTO player_in_team (id_player, id_team) VALUES (14, 9);
INSERT INTO player_in_team (id_player, id_team) VALUES (15, 9);
INSERT INTO player_in_team (id_player, id_team) VALUES (16, 9);
INSERT INTO player_in_team (id_player, id_team) VALUES (17, 9);
INSERT INTO player_in_team (id_player, id_team) VALUES (18, 9);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 13 AND id_team = 9;
INSERT INTO player_in_team (id_player, id_team) VALUES (19, 4);
INSERT INTO player_in_team (id_player, id_team) VALUES (20, 4);
INSERT INTO player_in_team (id_player, id_team) VALUES (21, 4);
INSERT INTO player_in_team (id_player, id_team) VALUES (22, 4);
INSERT INTO player_in_team (id_player, id_team) VALUES (23, 4);
INSERT INTO player_in_team (id_player, id_team) VALUES (24, 4);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 19 AND id_team = 4;
INSERT INTO player_in_team (id_player, id_team) VALUES (25, 2);
INSERT INTO player_in_team (id_player, id_team) VALUES (26, 2);
INSERT INTO player_in_team (id_player, id_team) VALUES (27, 2);
INSERT INTO player_in_team (id_player, id_team) VALUES (28, 2);
INSERT INTO player_in_team (id_player, id_team) VALUES (29, 2);
INSERT INTO player_in_team (id_player, id_team) VALUES (30, 2);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 25 AND id_team = 2;
INSERT INTO player_in_team (id_player, id_team) VALUES (31, 3);
INSERT INTO player_in_team (id_player, id_team) VALUES (32, 3);
INSERT INTO player_in_team (id_player, id_team) VALUES (33, 3);
INSERT INTO player_in_team (id_player, id_team) VALUES (34, 3);
INSERT INTO player_in_team (id_player, id_team) VALUES (35, 3);
INSERT INTO player_in_team (id_player, id_team) VALUES (36, 3);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 31 AND id_team = 3;
INSERT INTO player_in_team (id_player, id_team) VALUES (37, 1);
INSERT INTO player_in_team (id_player, id_team) VALUES (38, 1);
INSERT INTO player_in_team (id_player, id_team) VALUES (39, 1);
INSERT INTO player_in_team (id_player, id_team) VALUES (40, 1);
INSERT INTO player_in_team (id_player, id_team) VALUES (41, 1);
INSERT INTO player_in_team (id_player, id_team) VALUES (42, 1);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 37 AND id_team = 1;
INSERT INTO player_in_team (id_player, id_team) VALUES (43, 7);
INSERT INTO player_in_team (id_player, id_team) VALUES (44, 7);
INSERT INTO player_in_team (id_player, id_team) VALUES (45, 7);
INSERT INTO player_in_team (id_player, id_team) VALUES (46, 7);
INSERT INTO player_in_team (id_player, id_team) VALUES (47, 7);
INSERT INTO player_in_team (id_player, id_team) VALUES (48, 7);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 43 AND id_team = 7;
INSERT INTO player_in_team (id_player, id_team) VALUES (49, 8);
INSERT INTO player_in_team (id_player, id_team) VALUES (50, 8);
INSERT INTO player_in_team (id_player, id_team) VALUES (51, 8);
INSERT INTO player_in_team (id_player, id_team) VALUES (52, 8);
INSERT INTO player_in_team (id_player, id_team) VALUES (53, 8);
INSERT INTO player_in_team (id_player, id_team) VALUES (54, 8);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 49 AND id_team = 8;
INSERT INTO player_in_team (id_player, id_team) VALUES (55, 13);
INSERT INTO player_in_team (id_player, id_team) VALUES (56, 13);
INSERT INTO player_in_team (id_player, id_team) VALUES (57, 13);
INSERT INTO player_in_team (id_player, id_team) VALUES (58, 13);
INSERT INTO player_in_team (id_player, id_team) VALUES (59, 13);
INSERT INTO player_in_team (id_player, id_team) VALUES (60, 13);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 55 AND id_team = 13;
INSERT INTO player_in_team (id_player, id_team) VALUES (61, 10);
INSERT INTO player_in_team (id_player, id_team) VALUES (62, 10);
INSERT INTO player_in_team (id_player, id_team) VALUES (63, 10);
INSERT INTO player_in_team (id_player, id_team) VALUES (64, 10);
INSERT INTO player_in_team (id_player, id_team) VALUES (65, 10);
INSERT INTO player_in_team (id_player, id_team) VALUES (66, 10);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 61 AND id_team = 10;
INSERT INTO player_in_team (id_player, id_team) VALUES (67, 11);
INSERT INTO player_in_team (id_player, id_team) VALUES (68, 11);
INSERT INTO player_in_team (id_player, id_team) VALUES (69, 11);
INSERT INTO player_in_team (id_player, id_team) VALUES (70, 11);
INSERT INTO player_in_team (id_player, id_team) VALUES (71, 11);
INSERT INTO player_in_team (id_player, id_team) VALUES (72, 11);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 67 AND id_team = 11;
INSERT INTO player_in_team (id_player, id_team) VALUES (73, 12);
INSERT INTO player_in_team (id_player, id_team) VALUES (74, 12);
INSERT INTO player_in_team (id_player, id_team) VALUES (75, 12);
INSERT INTO player_in_team (id_player, id_team) VALUES (76, 12);
INSERT INTO player_in_team (id_player, id_team) VALUES (77, 12);
INSERT INTO player_in_team (id_player, id_team) VALUES (78, 12);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 73 AND id_team = 12;
INSERT INTO player_in_team (id_player, id_team) VALUES (80, 14);
INSERT INTO player_in_team (id_player, id_team) VALUES (81, 14);
INSERT INTO player_in_team (id_player, id_team) VALUES (82, 14);
INSERT INTO player_in_team (id_player, id_team) VALUES (83, 14);
INSERT INTO player_in_team (id_player, id_team) VALUES (84, 14);
INSERT INTO player_in_team (id_player, id_team) VALUES (85, 14);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 80 AND id_team = 14;
INSERT INTO player_in_team (id_player, id_team) VALUES (86, 15);
INSERT INTO player_in_team (id_player, id_team) VALUES (87, 15);
INSERT INTO player_in_team (id_player, id_team) VALUES (88, 15);
INSERT INTO player_in_team (id_player, id_team) VALUES (89, 15);
INSERT INTO player_in_team (id_player, id_team) VALUES (90, 15);
INSERT INTO player_in_team (id_player, id_team) VALUES (91, 15);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 87 AND id_team = 15;
INSERT INTO player_in_team (id_player, id_team) VALUES (92, 16);
INSERT INTO player_in_team (id_player, id_team) VALUES (93, 16);
INSERT INTO player_in_team (id_player, id_team) VALUES (94, 16);
INSERT INTO player_in_team (id_player, id_team) VALUES (95, 16);
INSERT INTO player_in_team (id_player, id_team) VALUES (96, 16);
INSERT INTO player_in_team (id_player, id_team) VALUES (97, 16);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 92 AND id_team = 16;
INSERT INTO player_in_team (id_player, id_team) VALUES (1, 17);
INSERT INTO player_in_team (id_player, id_team) VALUES (60, 17);
INSERT INTO player_in_team (id_player, id_team) VALUES (23, 17);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 1 AND id_team = 17;
INSERT INTO player_in_team (id_player, id_team) VALUES (33, 18);
INSERT INTO player_in_team (id_player, id_team) VALUES (35, 18);
INSERT INTO player_in_team (id_player, id_team) VALUES (36, 18);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 33 AND id_team = 18;
INSERT INTO player_in_team (id_player, id_team) VALUES (5, 19);
INSERT INTO player_in_team (id_player, id_team) VALUES (79, 19);
INSERT INTO player_in_team (id_player, id_team) VALUES (48, 19);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 5 AND id_team = 19;
INSERT INTO player_in_team (id_player, id_team) VALUES (27, 20);
INSERT INTO player_in_team (id_player, id_team) VALUES (28, 20);
INSERT INTO player_in_team (id_player, id_team) VALUES (29, 20);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 27 AND id_team = 20;
INSERT INTO player_in_team (id_player, id_team) VALUES (15, 21);
INSERT INTO player_in_team (id_player, id_team) VALUES (16, 21);
INSERT INTO player_in_team (id_player, id_team) VALUES (17, 21);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 15 AND id_team = 21;
INSERT INTO player_in_team (id_player, id_team) VALUES (49, 22);
INSERT INTO player_in_team (id_player, id_team) VALUES (50, 22);
INSERT INTO player_in_team (id_player, id_team) VALUES (51, 22);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 49 AND id_team = 22;
INSERT INTO player_in_team (id_player, id_team) VALUES (2, 23);
INSERT INTO player_in_team (id_player, id_team) VALUES (6, 23);
INSERT INTO player_in_team (id_player, id_team) VALUES (52, 23);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 52 AND id_team = 23;
INSERT INTO player_in_team (id_player, id_team) VALUES (32, 24);
INSERT INTO player_in_team (id_player, id_team) VALUES (53, 24);
INSERT INTO player_in_team (id_player, id_team) VALUES (34, 24);
UPDATE player_in_team SET id_title = 2 WHERE id_player = 34 AND id_team = 24;
GO

CREATE TRIGGER insertInitialTourneyStatus 
ON tourney
	AFTER INSERT
AS
BEGIN
	DECLARE @idTourney INT;
	DECLARE @creationDate DATETIME;
	SELECT @idTourney = id FROM inserted;
	SELECT @creationDate = creation_date FROM inserted;

	INSERT INTO tourney_status (id_tourney, id_event_status, change_date) -- Inserts 'created' status
	VALUES (@idTourney, 1, @creationDate);
END;
GO

INSERT INTO tourney (id_created_by, id_tourney_setting, tourney_name, start_date)
VALUES (1, 3, 'WinterCup3vs3', DATEADD(DAY, 1, GETDATE()));
INSERT INTO tourney (id_created_by, id_tourney_setting, tourney_name, start_date)
VALUES (1, 4, 'WinterCup6vs6', DATEADD(DAY, 1, GETDATE()));
GO

CREATE FUNCTION countPlayersInTeam (
	@idTeam INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @result INT;

	SELECT @result = COALESCE(COUNT(pit.id_player), 0)
	FROM player_in_team pit
	WHERE id_team = @idTeam;

	RETURN @result;
END;
GO


CREATE FUNCTION getRequiredPlayersNumberInTeam (
	@idTourney INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @playersNumber INT;

	SELECT @playersNumber = RIGHT(mf.match_format, CHARINDEX('vs', mf.match_format) - 1)
	FROM match_format mf
	INNER JOIN tourney_setting ts
		ON ts.id_match_format = mf.id
	INNER JOIN tourney t
		ON t.id_tourney_setting = ts.id
	WHERE t.id = @idTourney;

	RETURN @playersNumber;
END;
GO

CREATE PROCEDURE getTeamsLimitAndNumber 
	@idTourney INT, 
	@teamsLimit INT OUTPUT, 
	@teamsNumber INT OUTPUT
AS
BEGIN
	SELECT @teamsLimit = tl.max_teams
	FROM teams_limit tl
	INNER JOIN tourney_setting ts
		ON ts.id_teams_limit = tl.id
	INNER JOIN tourney t
		ON t.id_tourney_setting = ts.id
	WHERE t.id = @idTourney;

	SELECT @teamsNumber = COALESCE(COUNT(id_tourney), 0)
	FROM team_plays_tourney
	WHERE id_tourney = @idTourney;
END;
GO

CREATE FUNCTION checkTeamsLimitStatus (
	@teamsLimit INT,
	@teamsNumber INT
)
	RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @status VARCHAR(20);

	IF (@teamsNumber > @teamsLimit)
		SET @status = 'exceeded';
	ELSE IF (@teamsNumber = @teamsLimit)
		SET @status = 'reached';

	RETURN @status;
END;
GO

/* For this project I will use random team seeding
 * In real-life situation, team seeds would be based either on one's preference
 * or calculated automatically, based on previous tournaments
 */
CREATE PROCEDURE generateTournamentSeeds
	@idTourney INT,
	@teamsLimit INT
AS
BEGIN
	DECLARE @counter INT;
	SET @counter = 1;

	CREATE TABLE tmpSeeds (
		seed INT PRIMARY KEY
	);

	WHILE (@counter <= @teamsLimit)
	BEGIN
		INSERT INTO tmpSeeds (seed) VALUES (@counter);
		SET @counter = @counter + 1;
	END;

	SET @counter = @teamsLimit;

	WHILE (@counter > 0)
	BEGIN
		DECLARE @seed INT;

		SELECT TOP 1 @seed = seed
		FROM tmpSeeds
		ORDER BY NEWID();

		UPDATE team_plays_tourney
		SET team_seed = @seed
		WHERE id_tourney = @idTourney AND id_team = (
			SELECT TOP 1 id_team
			FROM team_plays_tourney
			WHERE id_tourney = @idTourney AND team_seed IS NULL
		);

		DELETE FROM tmpSeeds WHERE seed = @seed;

		SET @counter = @counter - 1;
	END;

	DROP TABLE tmpSeeds;
END;
GO

CREATE PROCEDURE insertPlayersInMatch
	@idTeam INT,
	@idTourney INT,
	@idMatch INT
AS
BEGIN
	DECLARE @playersInMatch INT = dbo.getRequiredPlayersNumberInTeam(@idTourney);

	WHILE ((SELECT COALESCE(COUNT(id_player), 0) FROM player_plays_match WHERE id_tourney_match = @idMatch AND id_team = @idTeam) < @playersInMatch)
	BEGIN
		INSERT INTO player_plays_match (id_tourney_match, id_team, id_player)
		VALUES (@idMatch, @idTeam, 
			(SELECT TOP 1 id_player 
			FROM player_in_team 
			WHERE id_team = @idTeam AND id_player NOT IN (
				SELECT id_player FROM player_plays_match WHERE id_team = @idTeam AND id_tourney_match = @idMatch
			) ORDER BY id_title DESC));
	END;
END;
GO

CREATE TRIGGER generateMatchStatusAndPlayersInMatch
ON tourney_match
	AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @idMatch INT;
	DECLARE @type VARCHAR(6);
	DECLARE @idTeam1 INT;
	DECLARE @idTeam2 INT;
	DECLARE @idTourney INT;

	SELECT @idMatch = id FROM inserted;
	SELECT @idTourney = id_tourney FROM inserted;
	SELECT @idTeam1 = id_team1, @idTeam2 = id_team2 FROM inserted;

	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
		SET @type = 'insert';
	ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		SET @type = 'update';

	IF (@type = 'insert')
	BEGIN
		INSERT INTO match_status (id_tourney_match, id_event_status)
		VALUES (@idMatch, 1);

		IF (@idTeam1 IS NOT NULL AND @idTeam2 IS NOT NULL)
		BEGIN
			EXEC insertPlayersInMatch
				@idTeam1,
				@idTourney,
				@idMatch;
			EXEC insertPlayersInMatch
				@idTeam2,
				@idTourney,
				@idMatch;
		END;
		
	END;
	ELSE IF (@type = 'update')
	BEGIN
		IF (@idTeam1 IS NOT NULL)
			EXEC insertPlayersInMatch
				@idTeam1,
				@idTourney,
				@idMatch;
		IF (@idTeam2 IS NOT NULL)
			EXEC insertPlayersInMatch
				@idTeam2,
				@idTourney,
				@idMatch;
	END
END;
GO

CREATE PROCEDURE seedInserter
	@seeds seedTable READONLY
AS
BEGIN
	DECLARE @out seedTable;
	DECLARE @idSeed INT;
	DECLARE @newLength INT;
	DECLARE @oldLength INT;
	DECLARE @counter INT;
	DECLARE @seed1 INT;
	DECLARE @seed2 INT;

	SELECT @oldLength = COUNT(id)*2 FROM @seeds;
	SET @newLength = @oldLength * 2 + 1;

	SET @idSeed = 0;

	WHILE (1 = 1)
	BEGIN
		SELECT @idSeed = MIN(id) FROM @seeds WHERE id > @idSeed;
		IF @idSeed IS NULL BREAK;
		SELECT @seed1 = seed1, @seed2 = seed2 FROM @seeds WHERE id = @idSeed;
		INSERT INTO @out (seed1, seed2)
		VALUES (@seed1, @newLength-@seed1);
		INSERT INTO @out (seed1, seed2)
		VALUES (@seed2, @newLength-@seed2);
	END

	SELECT seed1, seed2 FROM @out;
END;
GO

CREATE PROCEDURE generateTournamentTree
	@idTourney INT,
	@maxSeed INT
AS
BEGIN
	DECLARE @fromHighestSeed INT;
	DECLARE @fromLowestSeed INT;
	DECLARE @highSeedTeam INT;
	DECLARE @lowSeedTeam INT;
	DECLARE @seedHelper seedTable;
	DECLARE @currentGameNumber INT;
	DECLARE @currentTourneyRound INT;
	DECLARE @maxGameNumber INT;
	DECLARE @maxRoundGames INT;
	DECLARE @maxRound INT;
	DECLARE @seeds seedTable;
	DECLARE @correctSeeds seedTable;
	DECLARE @seedTmp seedTable;

	SET @currentTourneyRound = 1;
	SET @fromHighestSeed = 1;
	SET @fromLowestSeed = @maxSeed;
	SET @maxGameNumber = @maxSeed - 1;
	SET @maxRoundGames = @maxSeed / 2;
	SET @maxRound = LOG(@maxSeed, 2)-1;

	INSERT INTO @seedTmp (seed1, seed2)
	VALUES (1, 2);

	DECLARE @counter INT;
	SET @counter = 0;

	WHILE (@counter < @maxRound)
	BEGIN
		DELETE FROM @seeds;

		INSERT @seeds (seed1, seed2)
		EXEC seedInserter
			@seedTmp

		DELETE FROM @seedTmp;
	
		INSERT INTO @seedTmp (seed1, seed2)
		SELECT seed1, seed2 FROM @seeds;
	
		SET @counter = @counter + 1;
	END;

	INSERT INTO @correctSeeds (seed1, seed2)
	SELECT seed1, seed2 FROM @seeds;
	
	WHILE (@fromHighestSeed < @fromLowestSeed)
	BEGIN
		SELECT @highSeedTeam = tpt.id_team
		FROM team_plays_tourney tpt
		WHERE id_tourney = @idTourney AND team_seed = @fromHighestSeed;

		SELECT @lowSeedTeam = tpt.id_team
		FROM team_plays_tourney tpt
		WHERE id_tourney = @idTourney AND team_seed = @fromLowestSeed;

		SELECT @currentGameNumber = id
		FROM @correctSeeds
		WHERE seed1 = @fromHighestSeed OR seed2 = @fromHighestSeed; 

		INSERT INTO tourney_match (id_team1, id_team2, id_tourney, game_number, tourney_round, match_date)
		VALUES (@highSeedTeam, @lowSeedTeam, @idTourney, @currentGameNumber, @currentTourneyRound, DATEADD(DAY, 2, GETDATE()));

		SET @fromHighestSeed = @fromHighestSeed + 1;
		SET @fromLowestSeed = @fromLowestSeed - 1;
	END;
	
	SELECT TOP 1 @currentGameNumber = id
	FROM @correctSeeds
	ORDER BY id DESC; 

	SET @currentGameNumber = @currentGameNumber + 1;
	
	WHILE (@currentGameNumber <= @maxGameNumber)
	BEGIN
		SET @maxRoundGames = @maxRoundGames / 2;
		SET @counter = 0;
		SET @currentTourneyRound = @currentTourneyRound + 1;
		WHILE (@counter < @maxRoundGames)
		BEGIN
			INSERT INTO tourney_match (id_tourney, game_number, tourney_round, match_date)
			VALUES (@idTourney, @currentGameNumber, @currentTourneyRound, DATEADD(DAY, 3, GETDATE()));
			SET @currentGameNumber = @currentGameNumber + 1;
			SET @counter = @counter + 1;
		END;
	END;

END;
GO

CREATE TRIGGER insertTeamInTournament
ON team_plays_tourney
	AFTER INSERT
AS
BEGIN
	DECLARE @idTourney INT;
	DECLARE @idTeam INT;
	DECLARE @teamsLimit INT;
	DECLARE @teamsNumber INT;
	DECLARE @teamsLimitStatus VARCHAR(20);


	SELECT @idTourney = id_tourney FROM inserted;
	SELECT @idTeam = id_team FROM inserted;

	EXEC getTeamsLimitAndNumber
		@idTourney,
		@teamsLimit OUTPUT,
		@teamsNumber OUTPUT;
	SET @teamsLimitStatus = dbo.checkTeamsLimitStatus(@teamsLimit, @teamsNumber);
	
	IF (dbo.getRequiredPlayersNumberInTeam(@idTourney) > dbo.countPlayersInTeam(@idTeam))
	BEGIN
		DELETE FROM team_plays_tourney
		WHERE id_team = @idTeam AND id_tourney = @idTourney;

		PRINT('Not enough players in team for this tournament.');
	END;
	ELSE IF (@teamsLimitStatus = 'exceeded')
	BEGIN
		DELETE FROM team_plays_tourney
		WHERE id_team = @idTeam AND id_tourney = @idTourney;

		PRINT('You can not add more teams in this tourney. Deleting previous inserted team.');
	END;
	ELSE IF(@teamsLimitStatus = 'reached')
	BEGIN
		PRINT('Teams limit reached -> generating random seeds');
		EXEC generateTournamentSeeds
			@idTourney,
			@teamsLimit;

		PRINT('Generating first round matches');
		EXEC generateTournamentTree
			@iDTourney,
			@teamsLimit;
	END;
		
END;
GO

INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 17);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 18);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 19);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 20);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 21);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 22);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 23);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (1, 24);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 1);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 2);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 3);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 4);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 5);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 6);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 7);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 8);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 9);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 10);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 11);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 12);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 13);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 14);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 15);
INSERT INTO team_plays_tourney (id_tourney, id_team) VALUES (2, 16);
GO

CREATE FUNCTION checkForBothScores(
	@idMatch INT,
	@idMap INT,
	@mapOrder INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @count INT;

	SELECT @count = COUNT(mm.id_tourney_match)
	FROM match_map mm
	WHERE mm.id_tourney_match = @idMatch AND mm.id_map = @idMap

	RETURN @count;
END;
GO

CREATE FUNCTION checkWinner(@idMatch INT, @idMap INT)
	RETURNS INT
AS
BEGIN
	DECLARE @idWinner INT;
	DECLARE @team1 INT;
	DECLARE @score1 INT;
	DECLARE @team2 INT;
	DECLARE @score2 INT;

	SELECT TOP 1 @team1 = mm.id_team, @score1 = mm.map_score
	FROM match_map mm
	WHERE id_tourney_match = @idMatch AND id_map = @idMap
	ORDER BY mm.map_score DESC;

	SELECT TOP 1 @team2 = mm.id_team, @score2 = mm.map_score
	FROM match_map mm
	WHERE id_tourney_match = @idMatch AND id_map = @idMap
	ORDER BY mm.map_score ASC;

	IF (@score1 = @score2)
		SET @idWinner = 0;
	ELSE IF (@score1 > @score2)
		SET @idWinner = @team1;
	ELSE
		SET @idWinner = @team2;

	RETURN @idWinner;
END;
GO

CREATE FUNCTION checkLoser(
	@idMatch INT,
	@idMap INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @idLoser INT;
	DECLARE @team1 INT;
	DECLARE @score1 INT;
	DECLARE @team2 INT;
	DECLARE @score2 INT;

	SELECT TOP 1 @team1 = mm.id_team, @score1 = mm.map_score
	FROM match_map mm
	WHERE id_tourney_match = @idMatch AND id_map = @idMap
	ORDER BY mm.map_score DESC;

	SELECT TOP 1 @team2 = mm.id_team, @score2 = mm.map_score
	FROM match_map mm
	WHERE id_tourney_match = @idMatch AND id_map = @idMap
	ORDER BY mm.map_score ASC;

	IF (@score1 = @score2)
		SET @idLoser = 0;
	ELSE IF (@score1 < @score2)
		SET @idLoser = @team1;
	ELSE
		SET @idLoser = @team2;

	RETURN @idLoser;
END;
GO

CREATE FUNCTION getNextGameNumber(
	@currentGameNumber INT,
	@maxGameNumberFirstRound INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @addition INT;
	DECLARE @newGameNumber INT;
	SET @addition = ROUND((@currentGameNumber * 1.0) / 2, 0);
	SET @newGameNumber = @maxGameNumberFirstRound + @addition;

	RETURN @newGameNumber;
END;
GO

CREATE PROCEDURE insertWinner
	@idMatch INT,
	@idWinner INT
AS
BEGIN
	DECLARE @currentTourneyRound INT;
	DECLARE @currentGameNumber INT;
	DECLARE @idTeam1 INT;
	DECLARE @idTeam2 INT;
	DECLARE @maxGameNumberInFirstRound INT;
	DECLARE @idTourney INT;
	DECLARE @lastTourneyMatch BIT;
	DECLARE @maxSeed INT;

	SELECT @currentTourneyRound = tm.tourney_round, @currentGameNumber = game_number, @idTourney = id_tourney
	FROM tourney_match tm
	WHERE tm.id = @idMatch;

	SELECT TOP 1 @maxSeed = tpt.team_seed
	FROM team_plays_tourney tpt
	WHERE tpt.id_tourney = @idTourney
	ORDER BY tpt.team_seed DESC;
	
	SELECT TOP 1 @maxGameNumberInFirstRound = tm.game_number
	FROM tourney_match tm
	WHERE tm.id_tourney = @idTourney AND tm.tourney_round = 1
	ORDER BY tm.game_number DESC;

	SET @currentGameNumber = dbo.getNextGameNumber(@currentGameNumber, @maxGameNumberInFirstRound);
	SET @currentTourneyRound = @currentTourneyRound + 1;

	SELECT @idTeam1 = tm.id_team1, @idTeam2 = tm.id_team2
	FROM tourney_match tm
	WHERE id_tourney = @idTourney AND game_number = @currentGameNumber;

	IF (@currentTourneyRound > LOG(@maxSeed, 2)) -- Sets 1st place and puts winning team in next round
	BEGIN
		UPDATE team_plays_tourney
		SET team_final_standing = 1
		WHERE id_tourney = @idTourney AND id_team = @idWinner;

		INSERT INTO tourney_status (id_tourney, id_event_status)
		VALUES (@idTourney, 2);
	END;
	ELSE IF (@idTeam1 IS NULL)
	BEGIN
		UPDATE tourney_match 
		SET id_team1 = @idWinner
		WHERE id_tourney = @idTourney AND game_number = @currentGameNumber;
	END;
	ELSE IF (@idTeam2 IS NULL)
		BEGIN
		UPDATE tourney_match 
		SET id_team2 = @idWinner
		WHERE id_tourney = @idTourney AND game_number = @currentGameNumber;
	END;

	INSERT INTO match_status (id_tourney_match, id_event_status) -- Update match_status to finished
	VALUES (@idMatch, 2);
END;
GO

CREATE FUNCTION getTeamPlacement(
	@idTourney INT,
	@idLoser INT
)
	RETURNS VARCHAR(20)
BEGIN
	DECLARE @placement VARCHAR(20);
	DECLARE @roundMaxTeams INT;
	DECLARE @minPos INT;
	DECLARE @maxPos INT;

	SELECT @roundMaxTeams = (COUNT(tm.id)*2)
	FROM tourney_match tm
	WHERE tm.id_tourney = @idTourney AND tm.tourney_round = (
		SELECT TOP 1 tm.tourney_round
		FROM tourney_match tm
		WHERE id_team1 = @idLoser OR id_team2 = @idLoser
		ORDER BY tm.tourney_round DESC
	);

	SET @minPos = @roundMaxTeams;
	SET @maxPos = @roundMaxTeams / 2 + 1;
	IF (@roundMaxTeams = 2)
		SET @placement = 2;
	ELSE
		SET @placement = CAST(@minPos AS VARCHAR) + ' - ' + CAST(@maxPos AS VARCHAR);

	RETURN @placement;

END;
GO

CREATE FUNCTION getLoserId(
	@idMatch INT,
	@idWinner INT
)
	RETURNS INT
AS
BEGIN
	DECLARE @loserId INT;

	SELECT @loserId = mm.id_team
	FROM match_map mm
	WHERE NOT mm.id_team = @idWinner AND mm.id_tourney_match = @idMatch; 

	RETURN @loserId;
END;
GO

CREATE PROCEDURE insertDropoutPlacement
	@idMatch INT,
	@idLoser INT
AS
BEGIN
	DECLARE @idTourney INT;
	DECLARE @placement VARCHAR(20);

	SELECT @idTourney = tm.id_tourney
	FROM tourney_match tm
	WHERE tm.id = @idMatch;

	SET @placement = dbo.getTeamPlacement(@idTourney, @idLoser);

	UPDATE team_plays_tourney
	SET team_final_standing = @placement
	WHERE id_tourney = @idTourney AND id_team = @idLoser;
END;
GO

CREATE TRIGGER lookForWinner
ON match_map
	AFTER INSERT
AS
BEGIN
	DECLARE @idMatch INT;
	DECLARE @idMap INT;
	DECLARE @mapOrder INT;
	DECLARE @idWinner INT;
	DECLARE @idLoser INT;
	
	SELECT @idMatch = id_tourney_match FROM inserted;
	SELECT @idMap = id_map FROM inserted;

	IF (dbo.checkForBothScores(@idMatch, @idMap, @mapOrder) = 2)
	BEGIN
		SET @idWinner = dbo.checkWinner(@idMatch, @idMap);
		SET @idLoser = dbo.checkLoser(@idMatch, @idMap);
		
		IF NOT (@idWinner = 0 AND @idLoser = 0)
		BEGIN
			EXEC insertWinner
				@idMatch,
				@idWinner
			EXEC insertDropoutPlacement
				@idMatch,
				@idLoser
		END;

	END;
END;
GO

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (1, 1, (SELECT id_team1 FROM tourney_match WHERE id = 1), 1);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (1, 1, (SELECT id_team2 FROM tourney_match WHERE id = 1), 1);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (1, 2, (SELECT id_team1 FROM tourney_match WHERE id = 1), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (1, 2, (SELECT id_team2 FROM tourney_match WHERE id = 1), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (2, 1, (SELECT id_team1 FROM tourney_match WHERE id = 2), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (2, 1, (SELECT id_team2 FROM tourney_match WHERE id = 2), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (3, 3, (SELECT id_team1 FROM tourney_match WHERE id = 3), 0);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (3, 3, (SELECT id_team2 FROM tourney_match WHERE id = 3), 2);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (4, 4, (SELECT id_team1 FROM tourney_match WHERE id = 4), 0);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (4, 4, (SELECT id_team2 FROM tourney_match WHERE id = 4), 2);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (5, 1, (SELECT id_team1 FROM tourney_match WHERE id = 5), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (5, 1, (SELECT id_team2 FROM tourney_match WHERE id = 5), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (6, 1, (SELECT id_team1 FROM tourney_match WHERE id = 6), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (6, 1, (SELECT id_team2 FROM tourney_match WHERE id = 6), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (7, 2, (SELECT id_team1 FROM tourney_match WHERE id = 7), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (7, 2, (SELECT id_team2 FROM tourney_match WHERE id = 7), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (8, 2, (SELECT id_team1 FROM tourney_match WHERE id = 8), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (8, 2, (SELECT id_team2 FROM tourney_match WHERE id = 8), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (9, 2, (SELECT id_team1 FROM tourney_match WHERE id = 9), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (9, 2, (SELECT id_team2 FROM tourney_match WHERE id = 9), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (10, 2, (SELECT id_team1 FROM tourney_match WHERE id = 10), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (10, 2, (SELECT id_team2 FROM tourney_match WHERE id = 10), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (11, 2, (SELECT id_team1 FROM tourney_match WHERE id = 11), 0);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (11, 2, (SELECT id_team2 FROM tourney_match WHERE id = 11), 2);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (12, 2, (SELECT id_team1 FROM tourney_match WHERE id = 12), 0);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (12, 2, (SELECT id_team2 FROM tourney_match WHERE id = 12), 2);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (13, 2, (SELECT id_team1 FROM tourney_match WHERE id = 13), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (13, 2, (SELECT id_team2 FROM tourney_match WHERE id = 13), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (14, 2, (SELECT id_team1 FROM tourney_match WHERE id = 14), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (14, 2, (SELECT id_team2 FROM tourney_match WHERE id = 14), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (15, 2, (SELECT id_team1 FROM tourney_match WHERE id = 15), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (15, 2, (SELECT id_team2 FROM tourney_match WHERE id = 15), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (16, 2, (SELECT id_team1 FROM tourney_match WHERE id = 16), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (16, 2, (SELECT id_team2 FROM tourney_match WHERE id = 16), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (17, 2, (SELECT id_team1 FROM tourney_match WHERE id = 17), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (17, 2, (SELECT id_team2 FROM tourney_match WHERE id = 17), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (18, 2, (SELECT id_team1 FROM tourney_match WHERE id = 18), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (18, 2, (SELECT id_team2 FROM tourney_match WHERE id = 18), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (19, 2, (SELECT id_team1 FROM tourney_match WHERE id = 19), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (19, 2, (SELECT id_team2 FROM tourney_match WHERE id = 19), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (20, 2, (SELECT id_team1 FROM tourney_match WHERE id = 20), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (20, 2, (SELECT id_team2 FROM tourney_match WHERE id = 20), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (21, 2, (SELECT id_team1 FROM tourney_match WHERE id = 21), 2);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (21, 2, (SELECT id_team2 FROM tourney_match WHERE id = 21), 0);

INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (22, 2, (SELECT id_team1 FROM tourney_match WHERE id = 22), 0);
INSERT INTO match_map (id_tourney_match, id_map, id_team, map_score)
VALUES (22, 2, (SELECT id_team2 FROM tourney_match WHERE id = 22), 2);

GO

CREATE VIEW playedMostMatches
AS
	SELECT p.nick_name, COUNT(ppm.id_player) AS games_played
	FROM player p
	INNER JOIN player_plays_match ppm
		ON p.id = ppm.id_player
	GROUP BY p.nick_name
	HAVING COUNT(ppm.id_player) = (
		SELECT TOP 1 COUNT(ppm.id_player) AS total
		FROM player_plays_match ppm
		GROUP BY ppm.id_player
		ORDER BY total DESC
	);
GO

CREATE VIEW victoriesInTournamentAsCaptain
AS
	SELECT p.nick_name AS Captain, t.team_name AS Team, COUNT(t.id) AS Times_won_with_this_team
	FROM player p
	INNER JOIN player_in_team pit
		ON pit.id_player = p.id
	INNER JOIN team t
		ON t.id = pit.id_team
	INNER JOIN team_plays_tourney tpt
		ON tpt.id_team = t.id
	WHERE pit.id_title = (
		SELECT tt.id
		FROM title tt
		WHERE tt.title_name = 'Captain'
	) AND tpt.team_final_standing = '1'
	GROUP BY p.nick_name, t.team_name;
GO

CREATE PROCEDURE roadToFinal
	@idTourney INT
AS
BEGIN
	SELECT t1.team_name AS Team1, t2.team_name AS Team2, SUM(mm1.map_score) AS Score1, SUM(mm2.map_score) AS Score2
	FROM tourney_match tm
	INNER JOIN team t1
		ON t1.id = tm.id_team1
	INNER JOIN team t2
		ON t2.id = tm.id_team2
	INNER JOIN match_map mm1
		ON tm.id_team1 = mm1.id_team
	INNER JOIN match_map mm2
		ON tm.id_team2 = mm2.id_team
	INNER JOIN team_plays_tourney tpt
		ON tpt.id_tourney = tm.id_tourney
	WHERE mm1.id_tourney_match = mm2.id_tourney_match 
		AND tm.id_tourney = @idTourney 
		AND NOT mm1.id_team = mm2.id_team 
		AND mm1.id_map = mm2.id_map
		AND  (tpt.id_team = tm.id_team1 AND tpt.team_final_standing = '1' OR tpt.id_team = tm.id_team2 AND tpt.team_final_standing = '1')
	GROUP BY t1.team_name, t2.team_name, tm.game_number
	ORDER BY tm.game_number ASC;

	SELECT t1.team_name AS Team1, t2.team_name AS Team2, SUM(mm1.map_score) AS Score1, SUM(mm2.map_score) AS Score2
	FROM tourney_match tm
	INNER JOIN team t1
		ON t1.id = tm.id_team1
	INNER JOIN team t2
		ON t2.id = tm.id_team2
	INNER JOIN match_map mm1
		ON tm.id_team1 = mm1.id_team
	INNER JOIN match_map mm2
		ON tm.id_team2 = mm2.id_team
	INNER JOIN team_plays_tourney tpt
		ON tpt.id_tourney = tm.id_tourney
	WHERE mm1.id_tourney_match = mm2.id_tourney_match 
		AND tm.id_tourney = @idTourney 
		AND NOT mm1.id_team = mm2.id_team 
		AND mm1.id_map = mm2.id_map
		AND  (tpt.id_team = tm.id_team1 AND tpt.team_final_standing = '2' OR tpt.id_team = tm.id_team2 AND tpt.team_final_standing = '2')
	GROUP BY t1.team_name, t2.team_name, tm.game_number
	ORDER BY tm.game_number ASC;
END;
GO

CREATE PROCEDURE getMatchScore
	@idMatch INT
AS
BEGIN
	SELECT t1.team_name AS Team1, t2.team_name AS Team2, SUM(mm1.map_score) AS Score1, SUM(mm2.map_score) AS Score2
	FROM tourney_match tm
	INNER JOIN team t1
		ON t1.id = tm.id_team1
	INNER JOIN team t2
		ON t2.id = tm.id_team2
	INNER JOIN match_map mm1
		ON tm.id_team1 = mm1.id_team
	INNER JOIN match_map mm2
		ON tm.id_team2 = mm2.id_team
	WHERE mm1.id_tourney_match = mm2.id_tourney_match AND mm1.id_tourney_match = @idMatch AND NOT mm1.id_team = mm2.id_team AND mm1.id_map = mm2.id_map
	GROUP BY t1.team_name, t2.team_name
END;
GO

CREATE PROCEDURE getTourneyLadder
	@idTourney INT
AS
BEGIN
	SELECT t1.team_name AS Team1, t2.team_name AS Team2, SUM(mm1.map_score) AS Score1, SUM(mm2.map_score) AS Score2
	FROM tourney_match tm
	INNER JOIN team t1
		ON t1.id = tm.id_team1
	INNER JOIN team t2
		ON t2.id = tm.id_team2
	INNER JOIN match_map mm1
		ON tm.id_team1 = mm1.id_team
	INNER JOIN match_map mm2
		ON tm.id_team2 = mm2.id_team
	WHERE mm1.id_tourney_match = mm2.id_tourney_match AND tm.id_tourney = @idTourney AND NOT mm1.id_team = mm2.id_team AND mm1.id_map = mm2.id_map
	GROUP BY t1.team_name, t2.team_name, tm.game_number
	ORDER BY tm.game_number ASC;
END;
GO

SELECT * FROM playedMostMatches;
SELECT * FROM victoriesInTournamentAsCaptain;

EXEC getTourneyLadder 2;
EXEC roadToFinal 2;