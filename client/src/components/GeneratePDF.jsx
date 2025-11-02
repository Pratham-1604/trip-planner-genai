import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

const GeneratePDF = ({ title, data, columns, filename }) => {
  const generatePDF = () => {
    const doc = new jsPDF();

    // Title
    doc.setFontSize(18);
    doc.text(title, 14, 20);

    // Table
    autoTable(doc, {
      head: [columns],
      body: data.map((row) => columns.map((col) => row[col])),
      startY: 30,
    });

    // Save
    doc.save(`${filename || "document"}.pdf`);
  };

  return (
    <button
      onClick={generatePDF}
      className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
    >
      Download PDF
    </button>
  );
};

export default GeneratePDF;
