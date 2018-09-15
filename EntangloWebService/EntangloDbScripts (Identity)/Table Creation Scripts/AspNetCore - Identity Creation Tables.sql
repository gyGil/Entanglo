/*#######################################################################################################
  #	TYPE: 		ASP.NET Core 2.0 Identity Library Migration Tables				#
  #	NAME:		AspNetCore - Identity Creation Tables						#
  #	SUMMARY: 	Creates all the tables required by the ASP.NET Core Entity Framework Identity	#
  #			Library that is normally automatically created by the Identity library when 	#
  #			using with Microsofts SQL Server however not easily (auto) created when using	#
  #			PostgreSQL server. That is why the auto-generated tables scripts were copied	#
  #			and manual generated for simplifying PostgreSQL migration.			#
  #	PARAMETERS:	N/A										#
  #	RETURNS:	N/A										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/


/* ######################################################################################
   #				REQUIRED IDENTITY TABLES				#
   ###################################################################################### */


CREATE TABLE public."AspNetRoles" (
    "Id" character varying(450) NOT NULL,
    "ConcurrencyStamp" text,
    "Name" character varying(256),
    "NormalizedName" character varying(256),
    CONSTRAINT pk_identityrole PRIMARY KEY ("Id")
);

CREATE TABLE public."AspNetUsers" (
    "Id" character varying(450) NOT NULL,
    "AccessFailedCount" integer NOT NULL,
    "ConcurrencyStamp" text,
    "Email" character varying(256),
    "EmailConfirmed" boolean NOT NULL,
    "LockoutEnabled" boolean NOT NULL,
    "LockoutEnd" timestamp without time zone,
    "NormalizedEmail" character varying(256),
    "NormalizedUserName" character varying(256),
    "PasswordHash" text,
    "PhoneNumber" text,
    "PhoneNumberConfirmed" boolean NOT NULL,
    "SecurityStamp" text,
    "TwoFactorEnabled" boolean NOT NULL,
    "UserName" character varying(256),
    CONSTRAINT pk_applicationuser PRIMARY KEY ("Id")
);

CREATE TABLE public."AspNetRoleClaims" (
    "Id" serial NOT NULL,
    "ClaimType" text,
    "ClaimValue" text,
    "RoleId" character varying(450),
    CONSTRAINT pk_identityroleclaim PRIMARY KEY ("Id"),
    CONSTRAINT fk_identityroleclaim_identityrole_roleid FOREIGN KEY ("RoleId")
        REFERENCES public."AspNetRoles" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE public."AspNetUserClaims" (
    "Id" serial NOT NULL,
    "ClaimType" text,
    "ClaimValue" text,
    "UserId" character varying(450),
    CONSTRAINT pk_identityuserclaim PRIMARY KEY ("Id"),
    CONSTRAINT fk_identityuserclaim_applicationuser_userid FOREIGN KEY ("UserId")
        REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE public."AspNetUserLogins" (
    "LoginProvider" character varying(450) NOT NULL,
    "ProviderKey" character varying(450) NOT NULL,
    "ProviderDisplayName" text,
    "UserId" character varying(450),
    CONSTRAINT pk_identityuserlogin PRIMARY KEY ("LoginProvider", "ProviderKey"),
    CONSTRAINT fk_identityuserlogin_applicationuser_userid FOREIGN KEY ("UserId")
        REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE public."AspNetUserRoles" (
    "UserId" character varying(450) NOT NULL,
    "RoleId" character varying(450) NOT NULL,
    CONSTRAINT pk_identityuserrole PRIMARY KEY ("UserId", "RoleId"),
    CONSTRAINT fk_identityuserrole_applicationuser_userid FOREIGN KEY ("UserId")
        REFERENCES public."AspNetUsers" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT fk_identityuserrole_identityrole_roleid FOREIGN KEY ("RoleId")
        REFERENCES public."AspNetRoles" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
