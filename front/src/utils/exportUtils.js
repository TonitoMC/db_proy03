import { jsPDF } from "jspdf";

import { autoTable } from "jspdf-autotable";


export const exportToCsv = (columns, data, filename = 'report.csv') => {
  if (!data || data.length === 0) {
    console.warn("No data to export.");
    return;
  }

  const header = columns.map(column => `"${column.label.replace(/"/g, '""')}"`).join(',');
  const rows = data.map(row => {
    return columns.map(column => {
      let cellValue = row[column.key];

      if (column.formatter) {
        cellValue = column.formatter(cellValue, row);
      }

      if (cellValue === null || cellValue === undefined) {
        cellValue = '';
      } else {
        cellValue = String(cellValue);
        cellValue = cellValue.replace(/"/g, '""');
        cellValue = `"${cellValue}"`;
      }

      return cellValue;
    }).join(',');
  });

  const csvString = [header, ...rows].join('\r\n');

  const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  if (link.download !== undefined) {
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  } else {
    window.open('data:text/csv;charset=utf-8,' + encodeURIComponent(csvString));
  }
};


export const exportTableToPdf = (columns, data, filename = 'report_table.pdf', title = 'Report Table') => {
  if (!data || data.length === 0) {
    console.warn("No data to export as table.");
    return;
  }

  const doc = new jsPDF();

  doc.setFontSize(16);
  doc.text(title, 14, 20);

  const head = [columns.map(column => column.label)];

  const body = data.map(row => {
    return columns.map(column => {
      let cellValue = row[column.key];

      if (column.formatter) {
        cellValue = column.formatter(cellValue, row);
      }

      if (cellValue === null || cellValue === undefined) {
        cellValue = '';
      } else {
        cellValue = String(cellValue);
      }
      return cellValue;
    });
  });


  autoTable(doc, {
    head: head,
    body: body,
    startY: 30,
    theme: 'striped',
    headStyles: {
      fillColor: [200, 200, 200],
      textColor: [0, 0, 0],
      fontStyle: 'bold'
    },
    bodyStyles: {
      textColor: [50, 50, 50]
    },
    alternateRowStyles: {
      fillColor: [240, 240, 240]
    },
    margin: { top: 25 },

    didDrawPage: function (data) {
      let pageNumber = doc.internal.getNumberOfPages();
      doc.setFontSize(10);
      doc.text('Page ' + pageNumber, data.settings.margin.left, data.doc.internal.pageSize.height - 10);
    }
  });

  doc.save(filename);
};
