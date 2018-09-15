using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DomainModels.AccountModels
{
    public class LoginWithRecoveryCodeModel
    {
            [Required]
            [DataType(System.ComponentModel.DataAnnotations.DataType.Text)]
            [Display(Name = "Recovery Code")]
            public string RecoveryCode { get; set; }
    }
}
