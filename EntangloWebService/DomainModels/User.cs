/// \file  User
///
/// Major <b>User.cs</b>
/// \details <b>Details</b>
/// -   This file models a user in the user table of the main database.
///     It contains multiple constructors for different levels of user creation.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;

namespace DomainModels
{
    public class User
    {
        public int Id { get; set; }
        public int UserKey { get; set; } = 0;
        public string UserName { get; set; } = "";
        public string UserPassword { get; set; } = "";
        public string Email { get; set; } = "";
        public string DatabaseName { get; set; } = "";          // Only used for the passing of the database name during creation for Entity Framework

        public List<Database> Databases { get; set; }
        public DateTime? UserCreated { get; set; } = null;
        public DateTime? UserModified { get; set; } = null;
        public DateTime? UserRemoved { get; set; } = null;

        public string Note { get; set; } = "";

        public User()
        {
            UserCreated = DateTime.Now;
            Databases = new List<Database>();
        }

        public User(string _userName)
        {
            UserName = _userName;

            UserCreated = DateTime.Now;
            Databases = new List<Database>();
        }

        public User(int _userKey, string _userName, string _password, string _email)
        {
            UserKey = _userKey;
            UserName = _userName;
            UserPassword = _password;
            Email = _email;

            UserCreated = DateTime.Now;
            Databases = new List<Database>();
        }

        public User(int _userKey, string _userName, string _email, string _databaseName, string _note)
        {
            UserKey = _userKey;
            UserName = _userName;
            Email = _email;

            Databases = new List<Database>();

            Database database = new Database();

            if (Databases.Count < 1)
            {
                database = new Database { Id = 1, DatabaseName = _databaseName };
            }
            else
            {
                database = new Database { Id = Databases.Count + 1, DatabaseName = _databaseName };
            }

            Databases.Add(database);

            if (UserCreated != null) { UserCreated = DateTime.Now; }
            else { UserModified = DateTime.Now; }

            Note = _note;
        }
    }
}
