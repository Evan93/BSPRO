using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BS23.Models
{
    public class PostViewModel
    {
        public int PostId { get; set; }
        public string PostDesc { get; set; }
        public int UserId { get; set; }
        public string Name { get; set; }
        public int totalPages { get; set; }
        public string LocalTime { get; set; }
        public int NumberOfCmnts { get; set; }
    }
}