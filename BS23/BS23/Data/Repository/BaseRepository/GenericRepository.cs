using BS23.Data.Repository.Interface;
using BS23.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;

using BS23.Models;

namespace BS23.Data.Repository.BaseRepository
{
    public class GenericRepository<T> : IRepository<T> where T : class
    {
       

        BS23Entities context = null;
        private DbSet<T> entities = null;

        private bool disposed = false;

        public GenericRepository(BS23Entities context)
        {
            this.context = context;
            entities = context.Set<T>();
        }

        /// <summary>
        /// Get Data From Database
        /// <para>Use it when to retive data through a stored procedure</para>
        /// </summary>
        public IEnumerable<T> ExecuteQuery(string spQuery, object[] parameters)
        {
            using (context = new BS23Entities())
            {
                return context.Database.SqlQuery<T>(spQuery, parameters).ToList();
            }
        }

        /// <summary>
        /// Get Single Data From Database
        /// <para>Use it when to retive single data through a stored procedure</para>
        /// </summary>
        public T ExecuteQuerySingle(string spQuery, object[] parameters)
        {
            using (context = new BS23Entities())
            {
                return context.Database.SqlQuery<T>(spQuery, parameters).FirstOrDefault();
            }
        }

        /// <summary>
        /// Insert/Update/Delete Data To Database
        /// <para>Use it when to Insert/Update/Delete data through a stored procedure</para>
        /// </summary>
        public int ExecuteCommand(string spQuery, object[] parameters)
        {
            int result = 0;
            try
            {
                using (context = new BS23Entities())
                {
                    result = context.Database.SqlQuery<int>(spQuery, parameters).FirstOrDefault();
                }
            }
            catch { }
            return result;
        }

      

        protected virtual void Dispose(bool disposing)
        {
            if (!this.disposed)
            {
                if (disposing)
                {
                    context.Dispose();
                }
            }
            this.disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}