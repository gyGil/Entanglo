/// Major <b>OCR View Models</b>
/// \details <b>Details</b>
/// - Model to contain image and file type to request OCR service
/// - Model to return result of OCR service from Entanglo service
///   
/// <ul><li>\author     Geun Young Gil & Marcus Rankin</li>
///     <li>\copyright  Entanglo - BillClub</li>"
/// </ul>

using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EntangloWebSite.ViewModels
{
    /// <summary>
    /// Model to request OCR service with image
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class OcrImgArgsModel
    {
        public OcrImgArgsModel() { }

        public string Base64_image { get; set; }
        public string FileType { get; set; }
    }

    /// <summary>
    /// result from OCR service
    /// - Locale: indicate language
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class OcrImgResultViewModel
    {
        public System.Net.HttpStatusCode StatusCode { get; set; }
        public string Locale { get; set; }
        public string Text { get; set; }
    }
}
