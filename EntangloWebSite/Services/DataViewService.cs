/// Major <b>Data View Service</b>
/// \details <b>Details</b>
/// -  This service provide to view data in database.
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>
using EntangloWebSite.ViewModels;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EntangloWebSite.Services
{
    public class DataViewService
    {
        // Local host
        // private const string servisHostUrl = @"https://localhost:44333";

        // Azure Service
        private const string servisHostUrl = @"https://entanglowebservice20180424101018.azurewebsites.net/";

        private const string readUserTablesUrl = @"/Entanglo/Read/UserTables";
        private const string readDataTableUrl = @"/Entanglo/Read/DataTable";
        private const string delProfileUrl = @"/Entanglo/Delete/Profile";
        private const string delProfileDataUrl = @"/Entanglo/Delete/ProfileData";
        private const string delUserTablesUrl = @"/Entanglo/Delete/UserTables";

        /// <summary>
        /// Get user tables
        /// </summary>
        /// <param></param>
        /// <returns>list of table names</returns>
        public async Task<List<string>> ReadUserTables()
        {
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + readUserTablesUrl;

                HttpResponseMessage response = await client.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {

                    var json = await response.Content.ReadAsStringAsync();
                    List<TableName> tableNames = JsonConvert.DeserializeObject<List<TableName>>(json);

                    List<string> ret = new List<string>();
                    foreach (TableName name in  tableNames)
                    {
                        ret.Add(name.table_name);
                    }
                    return ret;
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return null;
        }

        /// <summary>
        /// Get data in a table
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns>data in table</returns>
        public async Task<List<List<string>>> ReadDataTable(string tableName)
        {
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + readDataTableUrl + "?tableName=" + tableName;

                HttpResponseMessage response = await client.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    return JsonConvert.DeserializeObject<List<List<string>>>(json);
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return null;
        }

        /// <summary>
        /// Delete Profile in DB
        /// </summary>
        /// <param name=""></param>
        /// <returns>True: Success</returns>
        public async Task<bool> DeleteProfile()
        {
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + delProfileUrl;

                HttpResponseMessage response = await client.DeleteAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return false;
        }

        /// <summary>
        /// Delete Data in Profile in DB
        /// </summary>
        /// <param name=""></param>
        /// <returns>True: Success</returns>
        public async Task<bool> DeleteProfileData()
        {
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + delProfileDataUrl;

                HttpResponseMessage response = await client.DeleteAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return false;
        }

        /// <summary>
        /// Delete User Tables in DB
        /// </summary>
        /// <param name=""></param>
        /// <returns>True: Success</returns>
        public async Task<bool> DeleteUserTables()
        {
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + delUserTablesUrl;

                HttpResponseMessage response = await client.DeleteAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    return true;
                }
            }
            catch (Exception e)
            {
                throw e;
            }

            return false;
        }
    }
}
