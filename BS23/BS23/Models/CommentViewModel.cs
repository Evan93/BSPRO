using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BS23.Models
{
    public class CommentViewModel
    {
        public int PostId { get; set; }
     
  
        public string Name { get; set; }

        public string LocalTime { get; set; }
        public int NumberOfCmnts { get; set; }
        public int CommentId { get; set; }
        public int likeyes { get; set; }
        public int likeno { get; set; }
        public string CommentDesc { get; set; }
     
    }
}