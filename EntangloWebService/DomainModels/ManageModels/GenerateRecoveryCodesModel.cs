﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace DomainModels.ManageModels
{
    public class GenerateRecoveryCodesModel
    {
        public string[] RecoveryCodes { get; set; }
    }
}
