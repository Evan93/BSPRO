using BS23.Models;
using BS23.Service;
using System;
using System.Web.Mvc;

namespace BS23.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        private BS23Service bsService;

        public HomeController()
        {
          this.bsService = new BS23Service();
        }
        public ActionResult Index()
        {
            if (TempData["Msg"] != null) {
                ViewBag.Msg = TempData["Msg"];
            }

            return View();
        }

        public ActionResult UserLogIn( UserInfo UI)
        {
            UserInfo User = null;
            Session["Name"] = UI.Name;
            try
            {
                object[] parameters = { Session["Name"] };
                User = bsService.GetbyName(parameters);

                Session["Type"] = User.Type;
                Session["Id"] = User.UserId;
            }
            catch (Exception e) {
            
            }
            if (User != null)
            {

                return RedirectToAction("Index", "Dashboard", new { area = "" });
            }
            else {
                TempData["Msg"] ="Not A User";
                return RedirectToAction("Index", "Home", new { area = "" });
            }
        }
    }
}