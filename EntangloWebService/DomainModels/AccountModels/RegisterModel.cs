using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DomainModels.AccountModels
{
    public class RegisterModel
    {
        [Required]
        [EmailAddress]
        [Display(Name = "Email")]
        public string Email { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The User Name must be at least {0} and at max 50 characters long.", MinimumLength = 6)]
        [Display(Name = "UserName")]
        public string UserName { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The Phone Number must be at least {0} and at max 12 numbers long.", MinimumLength = 10)]
        [DataType(System.ComponentModel.DataAnnotations.DataType.PhoneNumber)]
        [Display(Name = "PhoneNumber")]
        public string PhoneNumber { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "The {0} must be at least {2} and at max {1} characters long.", MinimumLength = 6)]
        [DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }

        [DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [Display(Name = "ConfirmPassword")]
        [Compare("Password", ErrorMessage = "The password and confirmation password do not match.")]
        public string ConfirmPassword { get; set; }

        [Required]
        [Display(Name = "TableList")]
        public string[] TableList { get; set; }
    }
}
