public with sharing class MH_Doctor_ImportCsvController {

    public List<MH_Doctor_Service.CsvWrapper> wrappers { get; set; }
    public Blob csvFile { get; set; }
    public String csvAsString { get; set; }
    public List<String> csvLines { get; set; }

    public MH_Doctor_ImportCsvController() {
        csvLines = new List<String>();
        wrappers = new List<MH_Doctor_Service.CsvWrapper>();
    }

    public void process() {
        if(csvFile != null) {
            try {
                csvAsString = csvFile.toString();
                csvLines = csvAsString.split('\n');
                for (Integer i = 1; i < csvLines.size(); i++) {
                    String[] csvRecord = csvLines.get(i).split(',');
                    MH_Doctor_Service.CsvWrapper wrapper = MH_Doctor_Service.createWrapperFromArray(csvRecord);
                    wrappers.add(wrapper);
                }
            } catch (Exception e) {
                throw e;
            }
            csvFile = null;
            csvAsString = null;
            csvLines.clear();
        }
    }

    public void importDoctors() {
        wrappers = MH_Doctor_Service.importDoctors(wrappers);

    }

    public void all() {
        for (MH_Doctor_Service.CsvWrapper wrapper : wrappers) {
            wrapper.toImport = true;
        }
    }

    public void reverse() {
        for (MH_Doctor_Service.CsvWrapper wrapper : wrappers) {
            if (wrapper.toImport == true) {
                wrapper.toImport = false;
            } else {
                wrapper.toImport = true;
            }
        }
    }

    public void none() {
        for (MH_Doctor_Service.CsvWrapper wrapper : wrappers) {
            wrapper.toImport = false;
        }
    }
}