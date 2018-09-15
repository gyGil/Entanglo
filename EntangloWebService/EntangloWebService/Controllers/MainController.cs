/// \file  MainController
///
/// Major <b>MainController.cs</b>
/// \details <b>Details</b>
/// -   This file is a controller that handles all the service calls and
///     routing for the main Entanglo database like users, logging, data
///     profiles, roles and schemas.
///     
///     Note: Currently not implemented
///   
/// <ul><li>\author     Geunyoung Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using DomainModels;
using DatabaseServices;
using Npgsql;
using Microsoft.Extensions.Configuration;
//using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authorization;
using System.Diagnostics;

namespace EntangloWebService.Controllers
{
    //[Authorize]
    //[AutoValidateAntiforgeryToken]
    //[Produces("application/json")]
    //[Route("Entanglo/[controller]")]
    public class MainController : Controller
    {
        //private readonly UserManager<ApplicationUser> _userManager;
        //private readonly SignInManager<ApplicationUser> _signInManager;

        //public MainController(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager)
        //{
        //    //_userManager = userManager;
        //    //_signInManager = signInManager;
        //}
        public IActionResult Index()
        {
            return Ok("Index of Main Controller!");
        }

        [Authorize]
        public IActionResult About()
        {
            return Ok("About of Main Controller!");
        }

        public IActionResult Error()
        {
            return Ok(new Error { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        ////POST Main/Error
        //[HttpPost]
        //[Route("Error")]
        //public IActionResult Error()
        //{
        //    string errorMessage = "Exception Handler Error Occurred!";

        //    return Ok(errorMessage);
        //}

        //[HttpPost]
        //[AllowAnonymous]
        //[ValidateAntiForgeryToken]
        //[Route("Login")]
        //public async Task<IActionResult> Login(LoginCapture model)//, string returnUrl = null)
        //{
        //    //ViewData["ReturnUrl"] = returnUrl;
        //    if (ModelState.IsValid)
        //    {
        //        // This doesn't count login failures towards account lockout
        //        // To enable password failures to trigger account lockout, set lockoutOnFailure: true
        //        var result = await _signInManager.PasswordSignInAsync(model.Email, model.Password, model.RememberMe, lockoutOnFailure: false);
        //        if (result.Succeeded)
        //        {
        //            return Ok("Signed in Successfully"); //RedirectToLocal(returnUrl);
        //        }
        //        if (result.RequiresTwoFactor)
        //        {
        //            return Ok("Requires Two Factor Sign In");// RedirectToAction(nameof(SendCode), new { ReturnUrl = returnUrl, RememberMe = model.RememberMe });
        //        }
        //        if (result.IsLockedOut)
        //        {
        //            return View("Lockout");
        //        }
        //        else
        //        {
        //            ModelState.AddModelError(string.Empty, "Invalid login attempt.");
        //            return View(model);
        //        }
        //    }

        //    // If we got this far, something failed, redisplay form
        //    //return View(model);
        //    return Ok("Good");
        //}

        // GET api/values
        [HttpGet]
        public IEnumerable<string> Get()
        {
            //return new string[] { "value1", "value2" };
            return new string[] { "Entanglements..." };
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
