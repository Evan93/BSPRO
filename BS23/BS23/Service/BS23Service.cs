using BS23.Data.Repository.BaseRepository;
using BS23.Models;
using System.Collections.Generic;

namespace BS23.Service
{
    public partial class BS23Service
    {
        private GenericRepository<UserInfo> UserRepository;
        private GenericRepository<PostViewModel> PostRepository;
        private GenericRepository<CommentViewModel> CommentRepository;
        private GenericRepository<Vote> VoteRepository;
        public BS23Service()
        {
            this.UserRepository = new GenericRepository<UserInfo>(new BS23Entities());
            this.PostRepository = new GenericRepository<PostViewModel>(new BS23Entities());
            this.CommentRepository = new GenericRepository<CommentViewModel>(new BS23Entities());
            this.VoteRepository = new GenericRepository<Vote>(new BS23Entities());
        }

        //public IEnumerable<Customer> GetAll(object[] parameters)
        //{
        //    string spQuery = "[Get_Customer] {0}";
        //    return CustRepository.ExecuteQuery(spQuery, parameters);
        //}

        public UserInfo GetbyName(object[] parameters)
        {
            string spQuery = "[dbo].[GetInformationByName]  {0}";
            return UserRepository.ExecuteQuerySingle(spQuery, parameters);
        }


        public IEnumerable<PostViewModel> GetAllPosts(object[] parameters)
        {
            string spQuery = "[GetPostByID] {0},{1},{2}";
            return PostRepository.ExecuteQuery(spQuery, parameters);
        }

        public IEnumerable<CommentViewModel> GetAllCommentsByPost(object[] parameters)
        {
            string spQuery = "[GetAllCommentsByPost] {0}";
            return CommentRepository.ExecuteQuery(spQuery, parameters);
        }
    }
}