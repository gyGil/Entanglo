/// Major <b>NLP Service</b>
/// \details <b>Details</b>
/// -  This class provide NLP(Natural Language Processing) service to classify entities from text
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
    public class NlpService
    {
        /*
        *   [NOTE]
        *   Google and Watson NLP service api path and key was deleted for privacy protection
         */


        // Local host
        // private const string servisHostUrl = @"https://localhost:44333";

        // Azure Service
        private const string servisHostUrl = @"https://entanglowebservice20180424101018.azurewebsites.net/";

        private const string createProfileUrl = @"/Entanglo/Create/Profile";
        private const string createProfileDataUrl = @"/Entanglo/Create/ProfileData";
        private const string readProfileUrl = @"/Entanglo/Read/Profile";
        private const string createDataTableUrl = @"/Entanglo/Create/Table";
        private const string readProfileDataUrl = @"/Entanglo/Read/ProfileData";
        private const string insertDataIntoTableUrl = @"/Entanglo/Create/InsertData";

        const int FAIL_CREATE_PROFILE = -1;
        const int SUCCESS_INSERT_DATA = 0;
        const int FAIL_INSERT_DATA = -2;
        const int FAIL_FIND_PROFILE_DATA = -3;

        /// <summary>
        /// Request for NLP service
        /// </summary>
        /// <param name="model"></param>
        /// <returns>Entities</returns>
        public async Task<NlpMainResultViewModel> PostAsyncMainNlp(NlpArgModel model)
        {
            NlpMainResultViewModel nlpResult = new NlpMainResultViewModel();
            try
            {
                int ret = await InterMainNlpForEntity(model.Text, nlpResult);
                nlpResult.StatusCode = System.Net.HttpStatusCode.OK;
                nlpResult.Language = "en";
                nlpResult.ResultCode = ret;
                if (ret == SUCCESS_INSERT_DATA)
                    nlpResult.Note = "Success to insert data.";
                else if (ret > SUCCESS_INSERT_DATA)
                    nlpResult.Note = "ResultCode indicates the profile id";
                else if (ret == FAIL_CREATE_PROFILE)
                    nlpResult.Note = "Fail to create new profile.";
                else if (ret == FAIL_INSERT_DATA)
                    nlpResult.Note = "Fail to insert data.";
                else if (ret == FAIL_FIND_PROFILE_DATA)
                    nlpResult.Note = "Fail to find profile data.";
                else
                    nlpResult.Note = "Unknown error";
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return nlpResult;
        }

        /// <summary>
        /// Internal NLP by Regex and Watson Entities for Entity classification
        /// </summary>
        /// <param name="text"></param>
        /// <param name="nlpResult"></param>
        /// <param name="matchPercent">match percent with profile in DB (1.0 == 100%) </param>
        /// <returns>0: Success to insert data to DB
        ///          1 ~ : Created profile id
        ///          -1: Fail to create profile
        ///          -2: Fail to insert data
        /// </returns>
        private async Task<int> InterMainNlpForEntity(string text, NlpMainResultViewModel nlpResult, double matchPercent = 1.0)
        {
            int ret = FAIL_INSERT_DATA;

            List<NlpMainEntity> unknownEntities = new List<NlpMainEntity>();

            try
            {
                HttpClient client = new HttpClient();

                // Authentication or Authorization header
                string auth = string.Format("{0}:{1}", watsonNlpUsername, watsonNlpPassword);
                string auth64 = Convert.ToBase64String(Encoding.ASCII.GetBytes(auth));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", auth64);

                string[] lines = Regex.Split(text, @"\r?\n|\r");
                string key_val_deli = @":";

                // Identify Entities
                for (int i = 0; i < lines.Length; ++i)
                {
                    // Find key value pair
                    if (this.MainFindKeyValuePair(i, lines[i], key_val_deli, nlpResult))
                        continue;

                    // Find Regex Entities
                    if (this.MainFindEntity(i, lines[i], nlpResult))
                        continue;

                    // Remote Watson Request
                    string body = this.CreateReqBodyWatsonNlp(lines[i]);
                    var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
                    HttpResponseMessage response = await client.PostAsync(watsonNlpUrl, stringContent);

                    //nlpResult.StatusCode = response.StatusCode;
                    if (response.IsSuccessStatusCode)
                    {
                        string responseBody = await response.Content.ReadAsStringAsync();
                        dynamic responseObject = JObject.Parse(responseBody);
                        nlpResult.Language = responseObject.language;
                        bool doesEntityExist = false;
                        foreach (var item in responseObject.entities)
                        {
                            NlpMainEntity entity = new NlpMainEntity();
                            entity.Name = item.text;
                            entity.Type = item.type;
                            int startIdx = lines[i].IndexOf(entity.Name);
                            int endIdx = startIdx + entity.Name.Length - 1;
                            if (endIdx >= lines[i].Length - 1)
                                endIdx = -1;
                            entity.IndexInfo.Add(new NlpEntityIdexInfo(i, startIdx, endIdx));
                            nlpResult.Entities.Add(entity);
                            doesEntityExist = true;
                        }
                        if (doesEntityExist) continue;
                    }

                    // Parsing the words which is not identified for entities
                    string[] unknownWords = lines[i].Split();
                    int startIdx2 = 0;
                    int endIdx2 = 0;
                    for (int j = 0; j < unknownWords.Length; ++j)
                    {
                        if (unknownWords[j].Trim().Length < 1)
                        {
                            startIdx2 += unknownWords[j].Length + 1;
                            continue;
                        }                        
                        endIdx2 = startIdx2 + unknownWords[j].Length - 1;
                        if (j == unknownWords.Length - 1)
                            endIdx2 = -1;
                        NlpMainEntity entity = new NlpMainEntity();
                        entity.Type = Entity.Unknown;
                        entity.Name = unknownWords[j];
                        entity.IndexInfo.Add(new NlpEntityIdexInfo(i, startIdx2, endIdx2));
                        unknownEntities.Add(entity);
                        startIdx2 = endIdx2 + 2;
                    }
                }
                // Find profile
                if (nlpResult.Entities.Count < 1)
                {
                    Exception ex = new Exception("NLP Internal Error: Any Entity is not identified in text!");
                    throw ex;
                }

                (int similarity, int profile_id) = await FindProfile(nlpResult.Entities, false);

                // Determine whether most close profile is satisfied
                if (similarity >= (int)(nlpResult.Entities.Count * matchPercent) && profile_id > 0)
                {
                    // Find profileData
                    List<ResServiceProfileData> listProfileData = await FindProfileData(profile_id);

                    // If don't find profile data,  return profile id to send back to user to make them profile data
                    if (listProfileData == null || listProfileData.Count < 1)
                    {
                        nlpResult.Entities.AddRange(unknownEntities);
                        return profile_id;
                    }                        

                    // Extract Text from original text
                    InsertDataModel dataPoint = new InsertDataModel();
                    dataPoint.TableName = listProfileData[0].DataTableName;

                    foreach (NlpMainEntity entity in listProfileData[0].Recipe)
                    {
                        Colume col = new Colume();
                        col.Name = entity.Type;
                        string colVal = "";
                        foreach (NlpEntityIdexInfo idxInfo in entity.IndexInfo)
                        {
                            // line
                            if (idxInfo.line < lines.Length)
                            {
                                // start
                                if (idxInfo.start < lines[idxInfo.line].Length)
                                {
                                    if (idxInfo.end == -1)
                                    {
                                        colVal += lines[idxInfo.line].Substring(idxInfo.start);
                                    }
                                    else if (idxInfo.end < lines[idxInfo.line].Length)
                                    {
                                        colVal += lines[idxInfo.line].Substring(idxInfo.start, idxInfo.end + 1);
                                    }
                                }
                            }
                            colVal += " ";
                        }

                        col.Value = colVal;
                        dataPoint.Columns.Add(col);
                    }

                    if (await InsertDataIntoTable(dataPoint))
                        ret = SUCCESS_INSERT_DATA;
                }
                else
                {
                    if (!await CreateProfile(nlpResult.Entities))
                        ret = FAIL_CREATE_PROFILE;
                    else
                    {
                        (int new_similarity, int new_profile_id) = await FindProfile(nlpResult.Entities, false);
                        if (new_similarity >= (int)(nlpResult.Entities.Count * matchPercent))
                            ret = new_profile_id;
                    }
                }

                // attach unknown entities to result
                nlpResult.Entities.AddRange(unknownEntities);                
            }
            catch(Exception ex)
            {
                throw ex;
            }
          
            return ret;
        }

        /// <summary>
        /// create profile
        /// </summary>
        /// <param name="entities"></param>
        /// <returns></returns>
        private async Task<bool> CreateProfile(List<NlpMainEntity> entities)
        {
            bool createProfile = false;

            HttpClient client = new HttpClient();

            string url = servisHostUrl + createProfileUrl;
            string body = this.CreateReqBodyCreateProfile(entities);
            var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(url, stringContent);

            if (response.IsSuccessStatusCode)
                createProfile = true;

            return createProfile;
        }

        /// <summary>
        /// create profile data
        /// </summary>
        /// <param name="createArg"></param>
        /// <returns></returns>
        public async Task<bool> CreateProfileData(MainCreateArg createArg)
        {
            bool createProfileData = false;

            HttpClient client = new HttpClient();

            string url = servisHostUrl + createProfileDataUrl;
            string body = this.CreateReqBodyCreateProfileData(createArg);
            var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(url, stringContent);

            if (response.IsSuccessStatusCode)
                createProfileData = true;

            return createProfileData;
        }

        /// <summary>
        /// create table for inserting data points later
        /// </summary>
        /// <param name="createArg"></param>
        /// <returns></returns>
        public async Task<bool> CreateDataTable(MainCreateArg createArg)
        {
            
            bool createTable = false;

            HttpClient client = new HttpClient();

            string url = servisHostUrl + createDataTableUrl;
            string body = this.CreateReqBodyCreateDataTable(createArg);
            var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(url, stringContent);

            if (response.IsSuccessStatusCode)
                createTable = true;

            return createTable;
        }

        /// <summary>
        /// Insert data into table
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public async Task<bool> InsertDataIntoTable(InsertDataModel model)
        {
            bool ret = false;

            HttpClient client = new HttpClient();

            string url = servisHostUrl + insertDataIntoTableUrl;
            var content = JsonConvert.SerializeObject(model);
            var stringContent = new StringContent(content, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync(url, stringContent);

            if (response.IsSuccessStatusCode)
                return true;

            return ret;
        }


        /// <summary>
        /// Found the matched profile id
        /// </summary>
        /// <param name="entities">The list of entities found in text</param>
        /// <param name="checkValue">True: check value too</param>
        /// <returns>(max_sim, profile_id_max_sim)It will return max score for similarity
        ///         If checkValue Argument is true, it will go over the length of entities in case of value is matched
        /// </returns>
        public async Task<(int, int)> FindProfile(List<NlpMainEntity> entities, bool checkValue = false)
        {
            int max_sim = 0;    // Perfect match is equal to length of entities (similarity)
            int profile_id_max_sim = -1; // profile id having max match
            if (entities.Count < 1)
                return (0, -1);
            try
            {
                HttpClient client = new HttpClient();

                string url = servisHostUrl + readProfileUrl;

                HttpResponseMessage response = await client.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var json =  await response.Content.ReadAsStringAsync();
                    JArray patternList = JArray.Parse(json);

                    // Loop list of patterns
                    foreach (JObject item in patternList.Children<JObject>())
                    {
                        int sim = 0;
                        int profile_id = -1;
                        int idx_entities = 0;
                        foreach (JProperty property in item.Properties())
                        {
                            if (property.Name == "Id")
                            {
                                profile_id = (int)property.Value;
                            }
                            // Check each pattern for match
                            if (property.Name == "Pattern")
                            {
                                foreach (JObject pattern in property.Value.Children<JObject>())
                                {
                                    foreach (JProperty _property in pattern.Properties())
                                    {
                                        // Compare requested pattern and db pattern
                                        if (idx_entities < entities.Count)
                                        {
                                            if (_property.Name == entities[idx_entities].Type)
                                                ++sim;
                                            else
                                                --sim;

                                            // Check Value
                                            if (checkValue && (string)_property.Value == entities[idx_entities].Name)
                                                ++sim;
                                        }
                                        else
                                            --sim;
                                    }
                                    ++idx_entities;
                                }
                            }
                        }
                        // Set max similarity
                        if (sim > max_sim)
                        {
                            max_sim = sim;
                            profile_id_max_sim = profile_id;
                        }                            
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return (max_sim, profile_id_max_sim);
        }

        /// <summary>
        /// Return list of profile data which match with profile id
        /// </summary>
        /// <param name="profileId"></param>
        /// <returns></returns>
        public async Task<List<ResServiceProfileData>> FindProfileData(int profileId)
        {
            // get profile recipe list
            HttpClient client = new HttpClient();

            string url = servisHostUrl + readProfileDataUrl + @"?profileId=" + profileId.ToString();

            HttpResponseMessage response = await client.GetAsync(url);

            if (response.IsSuccessStatusCode)
            {
                List<ResServiceProfileData> profileData = new List<ResServiceProfileData>();
                var json = await response.Content.ReadAsStringAsync();
                profileData = JsonConvert.DeserializeObject<List<ResServiceProfileData>>(json);
                return profileData;
            }
                // parse recipe list to result 
            return null;
        }

        /// <summary>
        /// Find Only 1 key value pair and store to nlpResult
        /// </summary>
        /// <param name="lineNum">line number in original text</param>
        /// <param name="text">text on a line</param>
        /// <param name="nlpResult">pointer for result</param>
        /// <returns>true: fine a key-value pair, </returns>
        private bool MainFindKeyValuePair(int lineNum, string text, string key_val_deli, NlpMainResultViewModel nlpResult)
        {
            int idx_key_val_deli = text.IndexOf(key_val_deli);

            if (idx_key_val_deli > 0 && idx_key_val_deli < (text.Length - 1))
            {
                NlpMainEntity entity = new NlpMainEntity();
                entity.Type = Regex.Replace(text.Substring(0, idx_key_val_deli), @"\s+", "");
                entity.Name = text.Substring(idx_key_val_deli + 1);
                entity.IndexInfo.Add(new NlpEntityIdexInfo(lineNum, idx_key_val_deli + 1, -1));
                nlpResult.Entities.Add(entity);
                return true;
            }

            return false;
        }

        /// <summary>
        /// Find Entities in string
        /// </summary>
        /// <param name="text">This text is expected that new line characters are removed all</param>
        /// <param name="nlpResult"></param>
        /// <returns>Text after remove identified entity substring</returns>
        private bool MainFindEntity(int lineNum, string text, NlpMainResultViewModel nlpResult)
        {
            bool foundEntity = false;

            // Loop all pattern for entities
            foreach (KeyValuePair<string, string> entity in Entity.Name_Pattern)
            {
                var regex = new Regex(entity.Value, RegexOptions.IgnoreCase);
                foreach (Match match in regex.Matches(text))
                {
                    NlpMainEntity nlpEntity = new NlpMainEntity();
                    nlpEntity.Name = match.Value;
                    nlpEntity.Type = entity.Key;
                    int endIndex = match.Index + match.Length - 1;
                    if (endIndex >= text.Length - 1)
                        endIndex = -1;
                    NlpEntityIdexInfo idxInfo = new NlpEntityIdexInfo(lineNum, match.Index, endIndex);
                    nlpEntity.IndexInfo.Add(idxInfo);
                    nlpResult.Entities.Add(nlpEntity);
                    foundEntity = true;
                }
            }

            return foundEntity;
        }

        /// <summary>
        /// Request Google NLP
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public async Task<NlpResultViewModel> PostAsyncGoogleNlp(NlpArgModel model)
        {
            NlpResultViewModel nlpResult = new NlpResultViewModel();
            try
            {
                HttpClient client = new HttpClient();
                string body = this.CreateReqBodyGoogleNlp(model.Text);
                var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
                HttpResponseMessage response = await client.PostAsync(googleNlpUrl + googleNlpKey, stringContent);

                nlpResult.StatusCode = response.StatusCode;

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    dynamic responseObject = JObject.Parse(responseBody);
                    nlpResult.Language = responseObject.language;
                    foreach (var item in responseObject.entities)
                    {
                        NlpEntity entity = new NlpEntity();
                        entity.Name = item.name;
                        entity.Type = item.type;
                        nlpResult.Entities.Add(entity);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return nlpResult;
        }

        /// <summary>
        /// NLP request to Watson
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public async Task<NlpResultViewModel> PostAsyncWatsonNlp(NlpArgModel model)
        {
            NlpResultViewModel nlpResult = new NlpResultViewModel();
            try
            {
                HttpClient client = new HttpClient();

                // Authentication or Authorization header
                string auth = string.Format("{0}:{1}", watsonNlpUsername, watsonNlpPassword);
                string auth64 = Convert.ToBase64String(Encoding.ASCII.GetBytes(auth));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", auth64);

                // Internal Regex classification
                string noNewLineText = this.InterNlpForEntity(model.Text, nlpResult);

                string noSingleChacText = "";
                // Remove characters which have length 1
                foreach (var word in noNewLineText.Split())
                    if (word.Length > 1)
                        noSingleChacText += word + " ";

                // Remote Watson Request
                string body = this.CreateReqBodyWatsonNlp(noSingleChacText);
                var stringContent = new StringContent(body, Encoding.UTF8, "application/json");
                HttpResponseMessage response = await client.PostAsync(watsonNlpUrl, stringContent);

                nlpResult.StatusCode = response.StatusCode;

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    dynamic responseObject = JObject.Parse(responseBody);
                    nlpResult.Language = responseObject.language;
                    foreach (var item in responseObject.entities)
                    {
                        NlpEntity entity = new NlpEntity();
                        entity.Name = item.text;
                        entity.Type = item.type;                        
                        nlpResult.Entities.Add(entity);
                        noNewLineText = noNewLineText.Replace(entity.Name, " "); // Remove words which identified by Watson
                    }
                }

                // Split unidentified words to word and classify as unknown word 
                foreach (var word in noSingleChacText.Split(' ', StringSplitOptions.RemoveEmptyEntries))
                {
                    NlpEntity entity = new NlpEntity();
                    entity.Name = word;
                    entity.Type = Entity.Unknown;
                    nlpResult.Entities.Add(entity);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            } 

            return nlpResult;
        }

        /// <summary>
        /// Create Request body for Google NLP
        /// </summary> 
        /// <param name="text"></param>
        /// <param name="type"></param>
        /// <param name="language"></param>
        /// <returns></returns>
        private string CreateReqBodyGoogleNlp(string text, string type = "PLAIN_TEXT", string language = "EN")
        {
            JObject body = new JObject(
                new JProperty("document", new JObject(
                    new JProperty("type", type),
                    new JProperty("language", language),
                    new JProperty("content", text)
                )),
                new JProperty("encodingType","UTF8")
                );

            return body.ToString();
        }

        /// <summary>
        /// Create Request body for Watson NLP
        /// </summary>
        /// <param name="text"></param>
        /// <param name="type"></param>
        /// <param name="language"></param>
        /// <param name="maxEntities"></param>
        /// <param name="sentiment"></param>
        /// <returns></returns>
        private string CreateReqBodyWatsonNlp(string text, string type = "PLAIN_TEXT", string language = "EN", int maxEntities = 20, bool sentiment = true)
        {
            JObject body = new JObject(
                new JProperty("text", text),
                new JProperty("features", new JObject(
                    new JProperty("entities", new JObject(
                        new JProperty("sentiment", sentiment),
                        new JProperty("limit", maxEntities)
                        )
                    )
                )
            ));

            return body.ToString();
        }

        public string CreateReqBodyCreateProfile(List<NlpMainEntity> entities, string name = "", string user = "")
        {
            JArray pattern = new JArray();
            foreach (NlpMainEntity item in entities)
            {
                pattern.Add(
                    new JObject(
                        new JProperty(item.Type, item.Name)
                    )
                );
            }

            JObject body = new JObject(
                new JProperty("Name", name),
                new JProperty("Pattern", pattern.ToString()),
                new JProperty("User", user)
            );            

            return body.ToString(Formatting.None);
        }

        public string CreateReqBodyCreateProfileData(MainCreateArg createArg)
        {
            JArray entities = new JArray();
            foreach (NlpMainEntity item in createArg.Entities)
            {
                JArray listIdxInfo = new JArray();
                foreach (NlpEntityIdexInfo idxInfo in item.IndexInfo)
                {
                    listIdxInfo.Add(
                        new JObject(
                            new JProperty("line", idxInfo.line),
                            new JProperty("start", idxInfo.start),
                            new JProperty("end", idxInfo.end)
                        )
                    );
                }
                entities.Add(
                    new JObject(
                    new JProperty("IndexInfo", listIdxInfo),
                    new JProperty("Name", item.Name),
                    new JProperty("Type", item.Type)
                    )
                );                
            }

            JObject body = new JObject(
                new JProperty("ProfileId", createArg.ProfileId),
                new JProperty("DataTableName", createArg.TableName),
                new JProperty("Recipe", entities.ToString())
            );

            return body.ToString(Formatting.None);
        }
        

        public string CreateReqBodyCreateDataTable(MainCreateArg createArg, string schema="user", string tableUuid = "35A8C3B9-03F2-440C-AF72-D318A34D59F9")
        {
            JArray columns = new JArray();
            foreach (NlpMainEntity item in createArg.Entities)
            {
                columns.Add(
                        new JObject(
                            new JProperty("ColumnName", item.Type),
                            new JProperty("ColumnDataType", "text"),
                            new JProperty("ColumnSize", "100"),
                            new JProperty("ColumnConstraint", ""),
                            new JProperty("ColumnDefaultValue", "")
                        )
                    );
            }

            JObject body = new JObject(
                new JProperty("Schema", schema),
                new JProperty("TableName", createArg.TableName),
                new JProperty("TableUuid", tableUuid),
                new JProperty("JsonData", ""),
                new JProperty("TableColumns", columns)
            );

            return body.ToString(Formatting.None);
        }

        /// <summary>
        /// Internal NLP by Regex for Entity classification
        /// </summary>
        /// <param name="text"></param>
        /// <param name="nlpResult"></param>
        /// <returns>Return text which identified words are removed</returns>
        private string InterNlpForEntity(string text, NlpResultViewModel nlpResult)
        {
            string ret = "";
            string[] lines = Regex.Split(text, @"\r?\n|\r");

            // Identify Key-Value pair
            foreach (string line in lines)
            {
                //(int num_key_val, string unknown_key_val) = this.FindKeyValuePair(line, nlpResult);
                (int num_key_val, string unknown_key_val) = this.FindKeyValuePair(line, nlpResult, false);

                if (num_key_val < 1)
                    ret += line + " ";
                    //ret += line + " \n";
                else
                    ret += unknown_key_val + " ";
                    //ret += unknown_key_val + " \n";
                    
            }

            // Identify entities in whole text
            ret = this.FindEntity(ret, nlpResult);

            return ret;
        }

        /// <summary>
        /// Find key value pair and store to nlpResult
        /// </summary>
        /// <param name="text">Text to find key-value pair</param>
        /// <param name="nlpResult"> The container for key value pair</param>
        /// <param name="enableUnknown"> true: If key is not undefined previously, it categorized as unknown</param>
        /// <returns>The number of key-value pair</returns>
        private (int, string) FindKeyValuePair(string text, NlpResultViewModel nlpResult, bool enableUnknown = true)
        {
            const string KEY_VAL_DELI = @":";
            char[] KEY_VAL_PAIR_DELI = new char[] { ' ', '/' };
            string unknownKeyValue = "";

            //int num_key_val = 0;

            string[] splitedText = Regex.Split(text, KEY_VAL_DELI); // We expected which ':' is delimiter for key-value
            //string identifiedType = "";
            if (splitedText.Length > 1)
            {
                string identifiedType = "";

                string key = splitedText[0];
                string val = splitedText[splitedText.Length - 1];
                for (int i = 1; i < splitedText.Length - 1; ++i)
                {
                    string key_val = splitedText[i].Trim();
                    NlpEntity entity = new NlpEntity();
                    entity.Type = key;

                    // separate words between key-val delimiter (ex. key: value key: value)
                    int endIndex = key_val.LastIndexOfAny(KEY_VAL_PAIR_DELI);

                    // Set entity name and next type
                    if (endIndex < 1)
                        key = val = key_val;
                    else
                    {
                        val = key_val.Substring(0, endIndex + 1);
                        key = key_val.Substring(endIndex + 1);
                    }
                    entity.Name = val;

                    // Check whether entity type is unknown or not
                    identifiedType = Entity.EntityIdentifier(entity.Type, entity.Name);
                    if (enableUnknown == true && identifiedType == Entity.Unknown)
                        unknownKeyValue = " " + entity.Type + ": " + entity.Name;
                    else
                        nlpResult.Entities.Add(entity);
                }
                NlpEntity last_entity = new NlpEntity();
                last_entity.Type = key;
                last_entity.Name = val;
                if (enableUnknown == true && identifiedType == Entity.Unknown)
                    unknownKeyValue = " " + last_entity.Type + ": " + last_entity.Name;
                else
                    nlpResult.Entities.Add(last_entity);

            }

            return (splitedText.Length - 1, unknownKeyValue);
        }

        /// <summary>
        /// Find Entities in string
        /// </summary>
        /// <param name="text">This text is expected that new line characters are removed all</param>
        /// <param name="nlpResult"></param>
        /// <returns>Text after remove identified entity substring</returns>
        private string FindEntity(string no_newline_text, NlpResultViewModel nlpResult)
        {
            string ret = no_newline_text;
            foreach (KeyValuePair<string, string> entity in Entity.Name_Pattern)
            {
                var regex = new Regex(entity.Value, RegexOptions.IgnoreCase);                
                int start, end = 0;
                string patternRemovedText = "";
                foreach (Match match in regex.Matches(ret))
                {
                    NlpEntity nlpEntity = new NlpEntity();
                    nlpEntity.Name = match.Value.Trim();
                    nlpEntity.Type = entity.Key;
                    nlpResult.Entities.Add(nlpEntity);

                    // Remove found substring
                    start = match.Index;
                    patternRemovedText += ret.Substring(end, start - end) + " ";
                    end = start + match.Length;
                }

                // no match
                
                ret = patternRemovedText + ret.Substring(end);
            }
            
            return ret;
        }
    }



    /// <summary>
    /// Extended Entity type
    /// </summary>
    static public class Entity
    {
        // Extented Entities (Custom)
        static public string PhoneNumber = "PhoneNumber";
        static public string Fax = "Fax";
        static public string Url = "Url";
        static public string CanadianAddress = "NAAddress";
        static public string Unknown = "Unknown";


        // Key(Entity Type) Regex pattern
        static public Dictionary<string, string> Type_Pattern = new Dictionary<string, string> {
            { Entity.PhoneNumber,EntityPatternRegex.ENTITY_TYPE.PhoneNumber },
            { Entity.Fax,EntityPatternRegex.ENTITY_TYPE.Fax },
            { Entity.Url, EntityPatternRegex.ENTITY_TYPE.Url },
            { Entity.CanadianAddress, EntityPatternRegex.ENTITY_TYPE.CanadianAddress }
        };

        // Value(value matched with entity type) Regex pattern
        static public Dictionary<string, string> Name_Pattern = new Dictionary<string, string> {
            { Entity.PhoneNumber,EntityPatternRegex.NORTH_AMERICA.PhoneNumber },
            { Entity.Url, EntityPatternRegex.COMMON.Url },
            { Entity.CanadianAddress, EntityPatternRegex.NORTH_AMERICA.CANADA.CanadianAddress }
        };

        /// <summary>
        /// Identify value for key of entity
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <returns>Expected Key</returns>
        static public string EntityIdentifier(string type, string name)
        {
            foreach (KeyValuePair<string, string> entity in Entity.Name_Pattern)
            {
                var regex = new Regex(entity.Value, RegexOptions.IgnoreCase);
                if (regex.IsMatch(name))
                {
                    // Identify between phone and fax
                    if (entity.Key == Entity.PhoneNumber)
                    {
                        var fax_regex = new Regex(Entity.Type_Pattern[Entity.Fax], RegexOptions.IgnoreCase);
                        if (fax_regex.IsMatch(type))
                            return Entity.Fax;
                    }
                    return entity.Key;
                }
            }
            return Entity.Unknown;
        }
    }

    /// <summary>
    /// Regex Pattern for entity
    /// </summary>
    static public class EntityPatternRegex
    {
        static public class ENTITY_TYPE
        {
            static public string PhoneNumber = @"";
            static public string Fax = @"(^F.?$|FAX\.?)";
            static public string Url = @"";
            static public string CanadianAddress = @"";
        }

        static public class COMMON
        {
            static public string Url = @"(?:^|[^@\.\w-])([a-z0-9]+:\/\/)?(\w(?!ailto:)\w+:\w+@)?([\w.-]+\.[a-z]{2,4})(:[0-9]+)?(\/.*)?(?=$|[^@\.\w-])";
        }

        static public class NORTH_AMERICA
        {
            static public string PhoneNumber = @"(([0-9]{1})*[- .(]*([0-9]{3})[- .)]*[0-9]{3}[- .]*[0-9]{4})+";
            static public string StreetAddr = @"(?:\d+\-?\d+)\s(?:[A-Za-z0-9.-]+\s+)+(?:Avenue|Lane|Road|Boulevard|Drive|Street|Ave|Dr|Rd|Blvd|Ln|Cres|St)\.?";
            static public string Unit = @"(?:Unit\s(\d+|[A-Za-z]))";

            static public class CANADA
            {
                static public string PROVINCE = @"Alberta|British Columbia|Manitoba|New Brunswick|Newfoundland and Labrador|Nova Scotia|Ontario|" +
                                                 @"Prince Edward Island|Quebec|Saskatchewan|Northwest Territories|Nunavut|Yukon";
                static public string PROVINCE_ABB = @"AB|BC|MB|N[BLTSU]|ON|PE|QC|SK|YT";
                static public string CITY_ON = @"Barrie|Belleville|Brampton|Brant|Brantford|Brockville|Burlington|Cambridge|Clarence-Rockland|Cornwall|" + 
                                             @"Dryden|Elliot Lake|Greater Sudbury|Guelph|Haldimand County|Hamilton|Kawartha Lakes|Kenora|Kingston|" +
                                             @"Kitchener|London|Markham|Mississauga|Niagara Falls|Norfolk County|North Bay|Orillia|Oshawa|Ottawa|" +
                                             @"Owen Sound|Pembroke|Peterborough|Pickering|Port Colborne|Prince Edward County|Quinte West|Sarnia|" +
                                             @"Sault Ste. Marie|St. Catharines|St. Thomas|Stratford|Temiskaming Shores|Thorold|Thunder Bay|Timmins|" +
                                             @"Toronto|Vaughan|Waterloo|Welland|Windsor|Woodstock";
                static public string PostalCode = @"[ABCEGHJKLMNPRSTVXY][0-9][A-Z] [0-9][A-Z][0-9]";
                /*
                 * (?:Unit\s(\d+|[A-Za-z]))?\,?\s?(?:\d+\-?\d+)\s(?:[A-Za-z0-9.-]+\s?)+(?:Avenue|Lane|Road|Boulevard|Cres|Drive|Street|Ave|Dr|Rd|Blvd|Ln|St)\.?\,?\s*(?:Unit\s(\d+|[A-Za-z]))?(\,?\s*(Barrie|Belleville|Brampton|Brant|Brantford|Brockville|Burlington|Cambridge|Clarence-Rockland|Cornwall|
Dryden|Elliot Lake|Greater Sudbury|Guelph|Haldimand County|Hamilton|Kawartha Lakes|Kenora|Kingston|
Kitchener|London|Markham|Mississauga|Niagara Falls|Norfolk County|North Bay|Orillia|Oshawa|Ottawa|
Owen Sound|Pembroke|Peterborough|Pickering|Port Colborne|Prince Edward County|Quinte West|Sarnia|
Sault Ste. Marie|St. Catharines|St. Thomas|Stratford|Temiskaming Shores|Thorold|Thunder Bay|Timmins|
Toronto|Vaughan|Waterloo|Welland|Windsor|Woodstock)(\,?\s+(Alberta|British Columbia|Manitoba|New Brunswick|Newfoundland and Labrador|Nova Scotia|Ontario|
Prince Edward Island|Quebec|Saskatchewan|Northwest Territories|Nunavut|Yukon|AB|BC|MB|N[BLTSU]|ON|PE|QC|SK|YT)\,?(\s*[ABCEGHJKLMNPRSTVXY][0-9][A-Z] [0-9][A-Z][0-9])?)?)?
                 */
                //static public string CanadianAddress = NORTH_AMERICA.Unit + @"?\,?\s?" + NORTH_AMERICA.StreetAddr + @"\,?\s*" + NORTH_AMERICA.Unit + @"?(\,?\s*(" +
                //                                       CANADA.CITY_ON + @")(\,?\s+(" + CANADA.PROVINCE + @"|" + CANADA.PROVINCE_ABB + @")\,?(\s*" + CANADA.PostalCode + @")?)?)?";
                static public string CanadianAddress = NORTH_AMERICA.Unit + @"?\,?\s?" + NORTH_AMERICA.StreetAddr + @"\,?\s+" + NORTH_AMERICA.Unit + @"?";
            }

            static public class USA
            {
                static public string STATE = @"Alabama|Alaska|Arizona|Arkansas|California|Colorado|Connecticut|Delaware|Florida|Georgia|Hawaii|" +
                                           @"Idaho|Illinois|Indiana|Iowa|Kansas|Kentucky|Louisiana|Maine|Maryland|Massachusetts|Michigan|" +
                                           @"Minnesota|Mississippi|Missouri|Montana|Nebraska|Nevada|New Hampshire|New Jersey|New Mexico|" +
                                           @"New York|North Carolina|North Dakota|Ohio|Oklahoma|Oregon|Pennsylvania|Rhode Island|South Carolina|" +
                                           @"South Dakota|Tennessee|Texas|Utah|Vermont|Virginia|Washington|West Virginia|Wisconsin|Wyoming";
                static public string STATE_ABB = @"A[KLRZ]|C[AOT]|D[CE]|FL|GA|HI|I[ADLN]|K[SY]|LA|M[ADEINOST]|N[CDEHJMVY]|O[HKR]|PA|RI|S[CD]|T[NX]|UT|V[AT]|W[AIVY]";
            }
        }
    }

}
