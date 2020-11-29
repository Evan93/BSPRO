using BS23.Models;
using BS23.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace BS23.Controllers
{
    public class DashboardController : Controller
    {
        private BS23Service bsService;
        public DashboardController()
        {
            this.bsService = new BS23Service();
        }
        // GET: Dashboard
        public ActionResult Index()
        {
            
            return View();
        }

        // GET: Dashboard/Details/5
        public JsonResult GetAllPosts(int page, int itemsperpage)
        {
            IEnumerable<PostViewModel> Posts = null;

            try
            {
                object[] parameters = { Session["Id"],page, itemsperpage };
                Posts = bsService.GetAllPosts(parameters);
            }
            catch (Exception e )
            {
            
            }
            return Json(Posts.ToList(), JsonRequestBehavior.AllowGet);
          
        }
        public JsonResult GetAllCommentsByPost(int PostId)
        {
            int Count = 10; IEnumerable<CommentViewModel> Comments = null;

            try
            {
                object[] parameters = { PostId };
                Comments = bsService.GetAllCommentsByPost(parameters);
            }
            catch { }
            return Json(Comments.ToList(), JsonRequestBehavior.AllowGet);

        }


    }
}
