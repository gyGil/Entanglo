using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace DatabaseServices
{
    public interface ISmsSender
    {
        Task SendSmsAsync(string number, string message);
    }
}
