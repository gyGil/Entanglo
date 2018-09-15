/// \file  ApplicationUser
///
/// Major <b>ApplicationUser.cs</b>
/// \details <b>Details</b>
/// -   This file models an application user in the ASP.NET Core Identity
///     Entity Framework for handling user Authorization and Authentication.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DomainModels
{
    public class ApplicationUser : IdentityUser
    {

        //#region Constructor
        //public ApplicationUser()
        //{
        //    UserCreated = DateTime.Now;
        //    Databases = new List<Database>();
        //}
        //#endregion

        [Required]
        public string[] TableList { get; set; } = { };

        //[Key]
        //[Required]
        //public string Id { get; set; }

        //[Required]
        //[MaxLength(128)]
        //public string UserName { get; set; }

        //[Required]
        //[MaxLength(256)]
        //public string Email { get; set; }

        //[Required]
        //[MaxLength(12)]
        //public string PhoneNumber { get; set; }


        //public string NormalizedUserName { get; set; }

        //[Required]
        //public DateTime UserCreated { get; set; }

        //public DateTime UserModified { get; set; }

        //public DateTime UserRemoved { get; set; }
    }
}
