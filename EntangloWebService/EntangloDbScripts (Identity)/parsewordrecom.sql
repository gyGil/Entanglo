/*#######################################################################################################
  #	TYPE: 		SQLCODE								#
  #	NAME:		parsewordrecom										#
  #	SUMMARY: 	Parse csv file and insert to table 					#
  #             (Note: change the file path for you)	#
  #	PARAMETERS:							#
  #	RETURNS:										#
  #	CREATED BY:	Geunyoung Gil and Marcus Rankin							#
  #######################################################################################################*/
COPY public.wordrecom("TargetWord", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20")
FROM 'C:\Users\ggil4920\Source\Repos\EntangloWebService\EntangloWebService\EntangloDbScripts (Identity)\data\entanglo_word_rec.csv' DELIMITER ',';
